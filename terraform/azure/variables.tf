variable "subscription_id" {
  description = "ID de la suscripción de Azure"
  type        = string
}

variable "location" {
  description = "Región de Azure (segunda nube en Fase 5). Fijada a eastus por cercanía geográfica a us-ashburn-1 (OCI), para minimizar latencia y costo de egress entre nubes, siguiendo el criterio de latencia del Marco Metodológico."
  type        = string
  default     = "eastus"
}

variable "project_prefix" {
  description = "Prefijo de nombres de recursos, para trazabilidad con el caso Supermercados LIMA"
  type        = string
  default     = "lima-vip"
}
