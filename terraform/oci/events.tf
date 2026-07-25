# Dispara la función automáticamente cuando se crea un objeto en el bucket de
# evidencia. Esto reemplaza la ejecución manual de scripts/analyze_image.py.
#
# ADVERTENCIA DE VERIFICACIÓN: el formato exacto del bloque "condition" (JSON de
# filtro por bucket) debe confirmarse contra la consola de OCI Events antes de
# depender de él en la demo - si el filtro no coincide, la regla se crea sin
# error pero simplemente nunca dispara. Recomendado: tras el apply, revisar en
# la consola (Developer Services > Events Service > Rules) que el filtro se
# vea como se espera, y hacer una prueba subiendo un objeto de prueba.

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
