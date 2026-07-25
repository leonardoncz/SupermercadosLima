"""
Dispara por OCI events cuando se crea objeto en el bucket.
Para autenticarse, se define en terraform/oci/iam_function.tfn
"""

import io
import json
import logging
import os
import time

import oci
import requests
from fdk import response


def handler(ctx, data: io.BytesIO = None):
    log = logging.getLogger()

    try:
        body = json.loads(data.getvalue())
    except Exception:
        log.error("No se pudo parsear el body del evento recibido")
        return response.Response(
            ctx, status_code=400,
            response_data=json.dumps({"error": "invalid event body"}),
            headers={"Content-Type": "application/json"},
        )

    try:
        event_data = body.get("data", {})
        additional = event_data.get("additionalDetails", {})
        bucket_name = additional.get("bucketName")
        namespace = additional.get("namespace") or os.environ.get("OCI_NAMESPACE")
        object_name = event_data.get("resourceName")

        if not bucket_name or not object_name or not namespace:
            raise ValueError(
                "El evento no trae bucketName/resourceName/namespace esperados; "
                "revisar el formato real del evento en la consola de OCI Events."
            )

        # No reprocesar los propios resultados si por error el bucket de salida
        # coincidiera con el de entrada (protección simple contra bucles).
        bucket_output = os.environ["BUCKET_OUTPUT"]
        if bucket_name == bucket_output:
            log.info("Objeto creado en bucket de salida, se ignora (evita bucle).")
            return response.Response(ctx, status_code=200, response_data=json.dumps({"status": "ignorado"}))

        signer = oci.auth.signers.get_resource_principals_signer()
        os_client = oci.object_storage.ObjectStorageClient(config={}, signer=signer)

        log.info(f"Descargando objeto: {bucket_name}/{object_name}")
        image_obj = os_client.get_object(namespace, bucket_name, object_name)
        image_bytes = image_obj.data.content

        vision_endpoint = os.environ["AZURE_VISION_ENDPOINT"]
        vision_key = os.environ["AZURE_VISION_KEY"]
        url = vision_endpoint.rstrip("/") + "/vision/v3.2/analyze"
        # Igual que en scripts/analyze_image.py: "People" no existe en v3.2;
        # la detección de personas se obtiene vía "Objects".
        params = {"visualFeatures": "Objects,Tags,Description"}
        headers = {
            "Ocp-Apim-Subscription-Key": vision_key,
            "Content-Type": "application/octet-stream",
        }

        log.info("Enviando imagen a Azure AI Vision...")
        vision_response = requests.post(url, params=params, headers=headers, data=image_bytes, timeout=30)
        if not vision_response.ok:
            log.error(f"Azure respondió {vision_response.status_code}: {vision_response.text}")
        vision_response.raise_for_status()
        result = vision_response.json()

        result_name = f"resultado-{int(time.time())}-{object_name}.json"
        os_client.put_object(
            namespace, bucket_output, result_name,
            json.dumps(result, ensure_ascii=False).encode("utf-8"),
        )
        log.info(f"Resultado guardado: {bucket_output}/{result_name}")

        return response.Response(
            ctx, status_code=200,
            response_data=json.dumps({"status": "ok", "resultado": result_name}),
            headers={"Content-Type": "application/json"},
        )

    except Exception as e:
        log.error(f"Error procesando el evento: {e}")
        return response.Response(
            ctx, status_code=500,
            response_data=json.dumps({"error": str(e)}),
            headers={"Content-Type": "application/json"},
        )
