locals {
    nsgrules = {
        grafana = {
            name = "grafana"
            priority = 100
            direction = "Inbound"
            access = "Allow"
            protocol = "Tcp"
            source_port_range = "*"
            destination_port_range = "3000"
            source_address_prefix = "MYIP"
            destination_address_prefix = "10.0.1.5"
        }

        loki = {
            name = "loki"
            priority = 101
            direction = "Inbound"
            access = "Allow"
            protocol = "Tcp"
            source_port_range = "*"
            destination_port_range = "3100"
            source_address_prefix = "VirtualNetwork"
            destination_address_prefix = "10.0.1.5"
        }

        target = {
            name = "target"
            priority = 102
            direction = "Inbound"
            access = "Allow"
            protocol = "Tcp"
            source_port_range = "*"
            destination_port_range = "8080" //ports for juice shop: was 3000 but need to do change maybe 8080 or 8008
            source_address_prefix = "MYIP"
            destination_address_prefix = "10.0.1.6"
        }

        promtail = {
            name = "promtail"
            priority = 103
            direction = "Inbound"
            access = "Allow"
            protocol = "Tcp"
            source_port_range = "*"
            destination_port_range = "9080"
            source_address_prefix = "VirtualNetwork"
            destination_address_prefix = "10.0.1.0/24"
        }

   
    }
}