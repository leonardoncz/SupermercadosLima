variable "tenancy_ocid" {
  description = "OCID del tenancy de OCI"
  type        = string
}

variable "user_ocid" {
  description = "OCID del usuario de OCI usado por Terraform"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint de la clave API de OCI"
  type        = string
}

variable "private_key_path" {
  description = "Ruta local a la clave privada de la API de OCI (NUNCA versionar este archivo)"
  type        = string
}

variable "region" {
  description = "Región primaria de OCI (según Fase 5, región primaria del proyecto)"
  type        = string
  default     = "sa-saopaulo-1"
}

variable "compartment_ocid" {
  description = "OCID del compartment donde se crean los buckets del prototipo"
  type        = string
}

variable "project_prefix" {
  description = "Prefijo de nombres de recursos, para trazabilidad con el caso Supermercados LIMA"
  type        = string
  default     = "lima-vip"
}
