resource "oci_identity_dynamic_group" "functions_dg" {
  compartment_id = var.tenancy_ocid
  name           = "${var.project_prefix}-functions-dg"
  description    = "Agrupa la función de análisis de imagen del prototipo Reconocimiento VIP"
  matching_rule  = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${var.compartment_ocid}'}"
}

resource "oci_identity_policy" "functions_policy" {
  compartment_id = var.compartment_ocid
  name           = "${var.project_prefix}-functions-policy"
  description    = "Permisos mínimos: la función solo gestiona objetos en los dos buckets del prototipo"

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.functions_dg.name} to manage objects in compartment id ${var.compartment_ocid} where target.bucket.name = '${oci_objectstorage_bucket.input_evidencia.name}'",
    "Allow dynamic-group ${oci_identity_dynamic_group.functions_dg.name} to manage objects in compartment id ${var.compartment_ocid} where target.bucket.name = '${oci_objectstorage_bucket.resultados_ia.name}'",
  ]
}

# Policy adicional requerida por OCI para que el servicio Functions pueda operar
# recursos de red (VNIC) dentro de tu VCN. Sin esta policy, la función no arranca.
resource "oci_identity_policy" "faas_network_policy" {
  compartment_id = var.compartment_ocid
  name           = "${var.project_prefix}-faas-network-policy"
  description    = "Permite al servicio FaaS usar la red de la VCN del prototipo"

  statements = [
    "Allow service faas to use virtual-network-family in compartment id ${var.compartment_ocid}",
  ]
}

resource "oci_identity_policy" "events_invoke_policy" {
  compartment_id = var.compartment_ocid
  name           = "${var.project_prefix}-events-invoke-policy"
  description    = "Permite que las reglas de Events invoquen funciones en este compartment"

  statements = [
    "Allow any-user to use fn-invocation in compartment id ${var.compartment_ocid} where request.principal.type = 'cloudevent'",
  ]
}
