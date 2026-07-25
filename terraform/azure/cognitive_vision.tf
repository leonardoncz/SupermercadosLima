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
