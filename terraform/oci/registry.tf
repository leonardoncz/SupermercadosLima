# OCI Functions usa el modelo Fn Project: el código se empaqueta como imagen de
# contenedor y se referencia desde un repositorio de OCI Registry (OCIR).
# El build+push de la imagen se hace fuera de Terraform (ver function/README.md);
# aquí solo se crea el repositorio donde esa imagen va a vivir.

resource "oci_artifacts_container_repository" "vip_repo" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.project_prefix}-repo"
  is_public      = false

  freeform_tags = {
    proyecto = "supermercados-lima"
    workload = "reconocimiento-vip-prototipo"
    fase     = "fase-5"
  }
}
