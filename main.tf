terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features{}
  }

#move to variables file and .tfvars for secrets
variable "siem" {
  default = "grafana"  
}

variable "target" {
  default = "juice-shop"  //might change
}

# variable "mint-key" {
#   default = "file('~/.ssh/id_rsa.pub')"
# }
#download azure cli and then login. that will provide auth. https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
# 1. Create the Reource group
# 2. Create vnet
#3. create subnet
# 4. create nic
# 5. Create NSG and allow ports and ip to vms
# 6. (IN main.tf) Create VMs for Grafana, Loki (docker containers in 1 vm) and target machines (maybe jump box for a public ip)
# 7. 

//need to add another target vm

resource "azurerm_resource_group" "project-rg" {
  name     = "-resources"
  location = "East US"
}

resource "azurerm_virtual_machine" "graf-vm" {
  name = "${var.siem}"
  location = azurerm_resource_group.project-rg.location
  resource_group_name = azurerm_resource_group.project-rg.name
  network_interface_ids = [ azurerm_network_interface.grafana-nic.id ]
  vm_size = "Standard_B1ms"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name = "grafanaosdisk1"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "graf-loki"
    admin_username = "grafadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true
  
    ssh_keys {
      key_data = "file('~/.ssh/id_rsa.pub')"
      path = "/home/{username}/.ssh/authorized_keys" //username of the mint user
    }  
  }
  //this is where provisioner "remote-exec" would be placed for ansible
}

resource "azurerm_virtual_machine" "target-vm" {
  name = "${var.target}"
  location = azurerm_resource_group.project-rg.location
  resource_group_name = azurerm_resource_group.project-rg.name
  network_interface_ids = [ azurerm_network_interface.target-nic.id ]
  vm_size = "Standard_B1ms"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name = "grafanaosdisk1"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "graf-loki"
    admin_username = "grafadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true
  
    ssh_keys {
      key_data = "file('~/.ssh/id_rsa.pub')"
      path = "/home/{username}/.ssh/authorized_keys" //username of the mint user
    }  
  }
  //this is where provisioner "remote-exec" would be placed for ansible
}
