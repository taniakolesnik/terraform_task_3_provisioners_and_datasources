# tfvmex-resources
data "azurerm_resource_group" "example" {
  name = "${var.prefix}-resources"
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "${var.prefix}-nic"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
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


resource "azurerm_virtual_machine" "example" {
  name                  = "${var.prefix}-vm"
  location              = data.azurerm_resource_group.example.location
  resource_group_name   = data.azurerm_resource_group.example.name
  network_interface_ids = [data.azurerm_network_interface.main.id]
  vm_size               = var.vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = azurerm_network_interface.example.private_ip_address
      user     = "testadmin"
      password = "Password1234!"
    }

    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx"
    ]
  }

  provisioner "file" {
    source      = "index.html"
    destination = "/usr/share/nginx/html/index.html"
    connection {
      type     = "ssh"
      host     = azurerm_network_interface.example.private_ip_address
      user     = "testadmin"
      password = "Password1234!"
    }
  }
}


