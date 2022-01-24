provider "azurerm" {
  features {}
}
data "azurerm_subnet" "subnet" {
  name                 = "default"
  virtual_network_name = "vnet2"
  resource_group_name  = "learning"
}
locals {
  current_time = timestamp()
  ist_time = timeadd(local.current_time,"5h30m")
  cal_time = timeadd(local.ist_time,"5m")
  format_time = formatdate("hhmm",local.cal_time)
}
resource "azurerm_network_interface" "vmnic" {
  name                = "vm-nic"
  location            = "eastus"
  resource_group_name = "Learning"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_virtual_machine" "virtualmachine" {
  name                  = "auto-shutdown"
  location              = "eastus"
  resource_group_name   = "Learning"
  network_interface_ids = [azurerm_network_interface.vmnic.id]
  vm_size               = "Standard_DS1_v2"
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
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
}
resource "azurerm_dev_test_global_vm_shutdown_schedule" "name" {
  virtual_machine_id = azurerm_virtual_machine.virtualmachine.id
  location           = "eastus"
  enabled            = true

  daily_recurrence_time = local.format_time
  timezone              = "India Standard Time"

  notification_settings {
    enabled         = true
    time_in_minutes = "60"
    email = "rajagopalanrg@outlook.com"
  }
}
output "indiantime" {
  value = local.ist_time
}
output "resulttime" {
  value = local.format_time
}