output "namespace" {
  description = "Namespace de Object Storage (requerido por el script Python)"
  value       = data.oci_objectstorage_namespace.ns.namespace
}

output "bucket_input_name" {
  description = "Nombre del bucket de entrada (imágenes de evidencia)"
  value       = oci_objectstorage_bucket.input_evidencia.name
}

output "bucket_output_name" {
  description = "Nombre del bucket de salida (resultados de Azure AI Vision)"
  value       = oci_objectstorage_bucket.resultados_ia.name
}

output "ocir_repo_path" {
  description = "Ruta del repositorio OCIR donde debe subirse la imagen de la función (build+push manual, ver function/README.md)"
  value       = "${var.ocir_region_key}.ocir.io/${data.oci_objectstorage_namespace.ns.namespace}/${oci_artifacts_container_repository.vip_repo.display_name}"
}

output "functions_application_name" {
  description = "Nombre de la aplicación de Functions (para usar con el CLI fn si se necesita)"
  value       = oci_functions_application.vip_app.display_name
}

output "function_id" {
  description = "OCID de la función desplegada"
  value       = oci_functions_function.analiza_imagen.id
}
