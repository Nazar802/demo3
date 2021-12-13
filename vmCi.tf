# Configure the Microsoft Azure Provider
provider "azurerm" {
 # The "feature" block is required for AzureRM provider 2.x.
 # If you're using version 1.x, the "features" block is not allowed.
 version = "~>2.0"
 features {}
}


# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
 name = "CI-RG"
 location = "eastus"
 tags = {
   environment = "Terraform Demo 3"
 }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
 name = "CI-Vnet"
 address_space = ["10.0.0.0/16"]
 location = "eastus"
 resource_group_name = azurerm_resource_group.myterraformgroup.name
 tags = {
   environment = "Terraform Demo 3"
 }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
 name = "CI-Subnet"
 resource_group_name = azurerm_resource_group.myterraformgroup.name
 virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
 address_prefixes = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
 name = "CI-PublicIP"
 location = "eastus"
 resource_group_name = azurerm_resource_group.myterraformgroup.name
 allocation_method = "Static"
 tags = {
   environment = "Terraform Demo 3"
 }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
 name = "CI-NSG"
 location = "eastus"
 resource_group_name = azurerm_resource_group.myterraformgroup.name
 security_rule {
   name = "SSH"
   priority = 1001
   direction = "Inbound"
   access = "Allow"
   protocol = "Tcp"
   source_port_range = "*"
   destination_port_range = "22"
   source_address_prefix = "*"
   destination_address_prefix = "*"
 }
 tags = {
   environment = "Terraform Demo 3"
 }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
 name = "CI-NIC"
 location = "eastus"
 resource_group_name = azurerm_resource_group.myterraformgroup.name
 ip_configuration {
 name = "CI-NicConfig"
 subnet_id = azurerm_subnet.myterraformsubnet.id
 private_ip_address_allocation = "Dynamic"
 public_ip_address_id = azurerm_public_ip.myterraformpublicip.id
 }
 tags = {
   environment = "Terraform Demo 3"
 }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
 network_interface_id = azurerm_network_interface.myterraformnic.id
 network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
 keepers = {
 # Generate a new ID only when a new resource group is defined
 resource_group = azurerm_resource_group.myterraformgroup.name
 }
 byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
 name = "diag${random_id.randomId.hex}"
 resource_group_name = azurerm_resource_group.myterraformgroup.name
 location = "eastus"
 account_tier = "Standard"
 account_replication_type = "LRS"
 tags = {
 environment = "Terraform Demo 3"
 }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
 algorithm = "RSA"
 rsa_bits = 4096
}

output "tls_private_key" {
 value = tls_private_key.example_ssh.private_key_pem
 sensitive = true
}

resource "azurerm_linux_virtual_machine" "citfvm" {
 name = "CI-VM8"
 location = "eastus"
 resource_group_name = azurerm_resource_group.myterraformgroup.name
 network_interface_ids = [azurerm_network_interface.myterraformnic.id]
 size = "Standard_D2s_v3"
 custom_data = filebase64("docker_edit.sh")

 os_disk {
   name = "ciDisk"
   caching = "ReadWrite"
   storage_account_type = "Premium_LRS"
 }
 source_image_reference {
   publisher = "Canonical"
   offer = "UbuntuServer"
   sku = "18.04-LTS"
   version = "latest"
 }
 computer_name = "CI-VM8"
 admin_username = "azureuser"
 disable_password_authentication = true
 admin_ssh_key {
   username = "azureuser"
   public_key = tls_private_key.example_ssh.public_key_openssh
 }
 boot_diagnostics {
   storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
 }
 tags = {
   environment = "Terraform Demo 3"
 }
}