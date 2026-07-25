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
