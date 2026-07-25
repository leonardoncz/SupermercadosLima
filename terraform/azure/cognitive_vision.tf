# Componente trazado a: Fase 5 - Región Azure - "Azure AI Vision"
# Workload de negocio: Reconocimiento VIP / Cámaras (Workload Inventory)
#
# Nota de alcance: se usa Azure AI Vision (Computer Vision / Image Analysis),
# NO Azure AI Face. Vision detecta presencia de personas (bounding boxes),
# objetos y etiquetas, sin identificar la identidad de nadie. Face requiere
# aprobación de Acceso Limitado de Microsoft y depende de la validación legal
# de datos biométricos en Perú, ambas pendientes y fuera del alcance del
# prototipo (ver docs/trazabilidad.md).

resource "azurerm_resource_group" "rg" {
  name     = "${var.project_prefix}-rg"
  location = var.location

  tags = {
    proyecto = "supermercados-lima"
    workload = "reconocimiento-vip-prototipo"
    ambiente = "prototipo"
    fase     = "fase-5"
  }
}

resource "azurerm_cognitive_account" "vision" {
  name                = "${var.project_prefix}-vision"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "ComputerVision"
  sku_name            = "F0" # Capa gratuita; suficiente para el volumen de un prototipo académico

  tags = {
    proyecto = "supermercados-lima"
    workload = "reconocimiento-vip-prototipo"
    ambiente = "prototipo"
    fase     = "fase-5"
  }
}
