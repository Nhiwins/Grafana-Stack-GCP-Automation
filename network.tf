#################################################################################
# Build the network infrastructure
# 2. Create vnet
# 3. create subnet
# 4. create nic
# 5. Create NSG and security rules
// need to add an ip and nic for the target machine
#################################################################################

resource "azurerm_virtual_network" "siem-vnet" {
  name                = "project-network"
  location            = azurerm_resource_group.project-rg.location
  resource_group_name = azurerm_resource_group.project-rg.name
  address_space       = ["10.0.0.0/16"]
  }

resource "azurerm_subnet" "subnet-1" {
  name                 = "${var.siem}-subnet"
  resource_group_name  = azurerm_resource_group.project-rg.name
  virtual_network_name = azurerm_virtual_network.siem-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Make a public ip for grafana
resource "azurerm_public_ip" "siem-ip" {
  name = "grafanaPublicIP"
  resource_group_name = azurerm_resource_group.project-rg.name
  location = azurerm_resource_group.project-rg.location
  allocation_method = "Static"

  lifecycle {
    create_before_destroy = true
  }
}

# make a public ip for target vm
resource "azurerm_public_ip" "target-ip" {
  name = "targetPublicIP"
  resource_group_name = azurerm_resource_group.project-rg.name
  location = azurerm_resource_group.project-rg.location
  allocation_method = "Static"
}

# make a nic for graf (both private and public)
resource "azurerm_network_interface" "grafana-nic" {
  name = "${var.siem}-nic"
  location = azurerm_resource_group.project-rg.location
  resource_group_name = azurerm_resource_group.project-rg.name
  virtual_machine_id = azurerm_virtual_machine.graf-vm.id

  ip_configuration {
    name = "${var.siem}ip-cfg"
    subnet_id = azurerm_subnet.subnet-1.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.1.5"
    public_ip_address_id = azurerm_public_ip.siem-ip.id
  }
}

resource "azurerm_network_interface" "target-nic" {
  name = "${var.target}-nic"
  location = azurerm_resource_group.project-rg.location
  resource_group_name = azurerm_resource_group.project-rg.name
  virtual_machine_id = azurerm_virtual_machine.target-vm.id

  ip_configuration {
    name = "${var.target}ip-cfg"
    subnet_id = azurerm_subnet.subnet-1.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.1.6"
    public_ip_address_id = azurerm_public_ip.target-ip.id
  }
}

# Create NSG with rules to allow ingress ports for grafana and loki
resource "azurerm_network_security_group" "project-NSG" {
  name                = "example-security-group"
  location            = azurerm_resource_group.project-rg.location
  resource_group_name = azurerm_resource_group.project-rg.name
}


# will need to decide on the two vuln server set up "juice shop, metasploitable, etc."
# and open ports to ip accordingly

#Other vms for grafana and loki will be secure and only open necessary ports
resource "azurerm_network_security_rule" "nsgrules" {
  for_each                    = local.nsgrules 
  name                        = each.key
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.project-rg.name
  network_security_group_name = azurerm_network_security_group.project-NSG.name
}

