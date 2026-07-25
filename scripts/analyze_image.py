"""
Credenciales en variables de entorno
"""

import os
import sys
import json
import time
import argparse

import requests
import oci


def get_oci_client(oci_config_path: str) -> oci.object_storage.ObjectStorageClient:
    config = oci.config.from_file(file_location=os.path.expanduser(oci_config_path))
    return oci.object_storage.ObjectStorageClient(config)


def upload_image_to_oci(client, namespace, bucket_name, object_name, file_path):
    with open(file_path, "rb") as f:
        client.put_object(namespace, bucket_name, object_name, f)
    print(f"[OCI] Imagen subida: {bucket_name}/{object_name}")


def analyze_with_azure_vision(image_path, endpoint, key):
    url = endpoint.rstrip("/") + "/vision/v3.2/analyze"
    # "People" no existe como visualFeature en la API v3.2 (esa capacidad
    # vive en Image Analysis 4.0, con otro endpoint). En v3.2, la detección
    # de personas se obtiene a través de "Objects" (incluye la etiqueta
    # "person" con su boundingBox), sin necesitar reconocimiento facial.
    params = {"visualFeatures": "Objects,Tags,Description"}
    headers = {
        "Ocp-Apim-Subscription-Key": key,
        "Content-Type": "application/octet-stream",
    }
    with open(image_path, "rb") as f:
        data = f.read()

    response = requests.post(url, params=params, headers=headers, data=data, timeout=30)
    if not response.ok:
        # Imprime el cuerpo del error de Azure antes de fallar: ahí viene
        # el motivo exacto (parámetro inválido, formato no soportado, etc.)
        print(f"[Azure] Respuesta de error ({response.status_code}): {response.text}")
    response.raise_for_status()
    return response.json()


def save_result_to_oci(client, namespace, bucket_name, object_name, result: dict):
    payload = json.dumps(result, indent=2, ensure_ascii=False).encode("utf-8")
    client.put_object(namespace, bucket_name, object_name, payload)
    print(f"[OCI] Resultado guardado: {bucket_name}/{object_name}")


def main():
    parser = argparse.ArgumentParser(
        description="Prototipo: Object Storage (OCI) + Azure AI Vision - Supermercados LIMA"
    )
    parser.add_argument("--image", required=True, help="Ruta local de la imagen de prueba (genérica/ficticia)")
    parser.add_argument("--namespace", required=True, help="Namespace de OCI Object Storage (output de Terraform)")
    parser.add_argument("--bucket-input", required=True, help="Bucket de entrada (output de Terraform)")
    parser.add_argument("--bucket-output", required=True, help="Bucket de salida (output de Terraform)")
    parser.add_argument("--oci-config", default="~/.oci/config", help="Ruta al archivo de configuración de OCI CLI")
    args = parser.parse_args()

    try:
        vision_endpoint = os.environ["AZURE_VISION_ENDPOINT"]
        vision_key = os.environ["AZURE_VISION_KEY"]
    except KeyError as e:
        sys.exit(f"Falta la variable de entorno {e}. Exporta AZURE_VISION_ENDPOINT y AZURE_VISION_KEY.")

    if not os.path.isfile(args.image):
        sys.exit(f"No se encontró la imagen: {args.image}")

    oci_client = get_oci_client(args.oci_config)
    object_name = os.path.basename(args.image)

    upload_image_to_oci(oci_client, args.namespace, args.bucket_input, object_name, args.image)

    print("[Azure] Enviando imagen a Azure AI Vision...")
    result = analyze_with_azure_vision(args.image, vision_endpoint, vision_key)

    result_name = f"resultado-{int(time.time())}-{object_name}.json"
    save_result_to_oci(oci_client, args.namespace, args.bucket_output, result_name, result)

    print("\n--- Resultado de Azure AI Vision ---")
    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
