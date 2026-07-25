variable "subscription_id" {
  description = "ID de la suscripción de Azure"
  type        = string
}

variable "location" {
  description = "Región de Azure (segunda nube en Fase 5)"
  type        = string
  default     = "brazilsouth"
}

variable "project_prefix" {
  description = "Prefijo de nombres de recursos, para trazabilidad con el caso Supermercados LIMA"
  type        = string
  default     = "lima-vip"
}
