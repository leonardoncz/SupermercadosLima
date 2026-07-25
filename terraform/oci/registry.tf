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
