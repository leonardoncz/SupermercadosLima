resource "oci_events_rule" "on_object_created" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.project_prefix}-evento-objeto-creado"
  description    = "Dispara analiza-imagen-vip cuando se crea un objeto en el bucket de evidencia"
  is_enabled     = true

  condition = jsonencode({
    eventType = ["com.oraclecloud.objectstorage.createobject"]
    data = {
      additionalDetails = {
        bucketName = [oci_objectstorage_bucket.input_evidencia.name]
      }
    }
  })

  actions {
    actions {
      action_type = "FAAS"
      is_enabled  = true
      function_id = oci_functions_function.analiza_imagen.id
    }
  }
}
