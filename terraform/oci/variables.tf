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
  description = "Región primaria de OCI. Fijada a us-ashburn-1: región home del tenancy universitario (Always Free), donde se generó la API key. Las cuentas Always Free/trial no permiten operar fuera de su región home sin upgrade."
  type        = string
  default     = "us-ashburn-1"
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

variable "azure_vision_endpoint" {
  description = "Endpoint de Azure AI Vision (copiar de: terraform output vision_endpoint en terraform/azure, tras aplicar ese stack)"
  type        = string
}

variable "azure_vision_key" {
  description = "Clave de Azure AI Vision (copiar de: terraform output -raw vision_primary_key en terraform/azure). Sensible: nunca commitear el valor real."
  type        = string
  sensitive   = true
}

variable "ocir_region_key" {
  description = "Prefijo de host de OCIR para la región. Para us-ashburn-1 es 'iad' (ver docs.oracle.com/iaas/Content/Registry/Concepts/registryoverview.htm#Availab si cambias de región)"
  type        = string
  default     = "iad"
}
