resource "oci_functions_application" "vip_app" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.project_prefix}-app"
  subnet_ids     = [oci_core_subnet.functions_subnet.id]

  config = {
    OCI_NAMESPACE       = data.oci_objectstorage_namespace.ns.namespace
    BUCKET_OUTPUT       = oci_objectstorage_bucket.resultados_ia.name
    AZURE_VISION_ENDPOINT = var.azure_vision_endpoint
  }

  freeform_tags = {
    proyecto = "supermercados-lima"
    workload = "reconocimiento-vip-prototipo"
    fase     = "fase-5"
  }
}

resource "oci_functions_function" "analiza_imagen" {
  application_id     = oci_functions_application.vip_app.id
  display_name       = "analiza-imagen-vip"
  image              = "${var.ocir_region_key}.ocir.io/${data.oci_objectstorage_namespace.ns.namespace}/${oci_artifacts_container_repository.vip_repo.display_name}/analiza-imagen:0.0.1"
  memory_in_mbs      = 512
  timeout_in_seconds = 60

  # La clave de Azure va como config de la FUNCIÓN (no de la aplicación) para
  # acotar su alcance. Sigue siendo texto plano en el state de Terraform: para
  # producción, reemplazar por referencia a OCI Vault (ver docs/trazabilidad.md).
  config = {
    AZURE_VISION_KEY = var.azure_vision_key
  }
}
