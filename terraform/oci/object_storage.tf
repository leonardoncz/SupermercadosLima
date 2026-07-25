# Componente trazado a: Fase 5 - Región OCI Primaria - "Object Storage"
# Workload de negocio: Reconocimiento VIP / Cámaras (Workload Inventory)

data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_ocid
}

# Bucket de entrada: imágenes de evidencia (genéricas/ficticias, nunca datos reales de personas)
resource "oci_objectstorage_bucket" "input_evidencia" {
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "${var.project_prefix}-evidencia-entrada"
  access_type    = "NoPublicAccess"
  versioning     = "Enabled"

  freeform_tags = {
    proyecto = "supermercados-lima"
    workload = "reconocimiento-vip-prototipo"
    ambiente = "prototipo"
    fase     = "fase-5"
  }
}

# Bucket de salida: resultado JSON de Azure AI Vision
resource "oci_objectstorage_bucket" "resultados_ia" {
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "${var.project_prefix}-resultados-ia"
  access_type    = "NoPublicAccess"
  versioning     = "Enabled"

  freeform_tags = {
    proyecto = "supermercados-lima"
    workload = "reconocimiento-vip-prototipo"
    ambiente = "prototipo"
    fase     = "fase-5"
  }
}

# Regla de ciclo de vida: evidencia técnica reutilizada del laboratorio IaaS_VM_LB_Storage
# (lifecycle/versionado), aplicada aquí como control de costo (FinOps) sobre datos de prueba.
resource "oci_objectstorage_object_lifecycle_policy" "entrada_lifecycle" {
  namespace = data.oci_objectstorage_namespace.ns.namespace
  bucket    = oci_objectstorage_bucket.input_evidencia.name

  rules {
    name        = "expirar-evidencia-prototipo"
    action      = "DELETE"
    time_amount = 30
    time_unit   = "DAYS"
    is_enabled  = true

    target = "objects"
  }
}
