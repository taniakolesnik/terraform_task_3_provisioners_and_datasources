# tfvmex-resources
data "azurerm_resource_group" "example" {
  name = "${var.prefix}-resources"
}

data "azurerm_virtual_network" "example" {
  name                = azurerm_virtual_network.example.name
  resource_group_name = data.azurerm_resource_group.example.name
  depends_on          = [azurerm_virtual_network.example]
}

data "azurerm_subnet" "internal" {
  name                 = azurerm_subnet.internal.name
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = data.azurerm_resource_group.example.name
  depends_on           = [azurerm_subnet.internal]
}

data "azurerm_network_interface" "example" {
  name                = azurerm_network_interface.example.name
  resource_group_name = data.azurerm_resource_group.example.name
  depends_on          = [azurerm_network_interface.example]
}

data "azurerm_virtual_machine" "example" {
  name                = azurerm_virtual_machine.example.name
  resource_group_name = data.azurerm_resource_group.example.name
  depends_on          = [azurerm_virtual_machine.example]
}