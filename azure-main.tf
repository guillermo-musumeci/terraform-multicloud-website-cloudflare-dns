#Configure the Azure Provider
provider "azurerm" { 
  environment     = "public"
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

#Create Resource Group
resource "azurerm_resource_group" "azure-rg" {
  name = "${var.app_name}-${var.app_environment}-rg"
  location = var.rg_location
}

#Create a virtual network
resource "azurerm_virtual_network" "azure-vnet" {
  name                = "${var.app_name}-${var.app_environment}-vnet"
  resource_group_name = azurerm_resource_group.azure-rg.name
  location            = var.rg_location
  address_space       = [var.azure_vnet_cidr]
  tags = { 
    environment = var.app_environment
  }
}

#Create a subnet
resource "azurerm_subnet" "azure-subnet" {
  name                 = "${var.app_name}-${var.app_environment}-subnet"
  resource_group_name  = azurerm_resource_group.azure-rg.name
  virtual_network_name = azurerm_virtual_network.azure-vnet.name
  address_prefix       = var.azure_subnet_cidr
}

#Create Security Group to access Web Server
resource "azurerm_network_security_group" "azure-web-nsg" {
  name                = "${var.app_name}-${var.app_environment}-web-nsg"
  location            = azurerm_resource_group.azure-rg.location
  resource_group_name = azurerm_resource_group.azure-rg.name

  security_rule {
    name                       = "AllowHTTP"
    description                = "Allow HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    description                = "Allow SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  tags = {
    environment = var.app_environment
  }
}

#Associate the Web NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "azure-web-nsg-association" {
  subnet_id                 = azurerm_subnet.azure-subnet.id
  network_security_group_id = azurerm_network_security_group.azure-web-nsg.id
}

#Get a Static Public IP
resource "azurerm_public_ip" "azure-web-ip" {
  name                = "${var.app_name}-${var.app_environment}-web-ip"
  location            = azurerm_resource_group.azure-rg.location
  resource_group_name = azurerm_resource_group.azure-rg.name
  allocation_method   = "Static"
  
  tags = { 
    environment = var.app_environment
  }
}

#Create Network Card for Web Server VM
resource "azurerm_network_interface" "azure-web-nic" {
  name                      = "${var.app_name}-${var.app_environment}-web-nic"
  location                  = azurerm_resource_group.azure-rg.location
  resource_group_name       = azurerm_resource_group.azure-rg.name
  network_security_group_id = azurerm_network_security_group.azure-web-nsg.id

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.azure-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azure-web-ip.id
  }

  tags = { 
    environment = var.app_environment
  }
}

# Create web server vm
resource "azurerm_virtual_machine" "azure-web-vm" {
  name                  = "${var.app_name}-${var.app_environment}-web-vm"
  location              = azurerm_resource_group.azure-rg.location
  resource_group_name   = azurerm_resource_group.azure-rg.name
  network_interface_ids = [azurerm_network_interface.azure-web-nic.id]
  vm_size               = "Standard_B1s"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.ubuntu-linux-publisher
    offer     = var.ubuntu-linux-offer  
    sku       = var.ubuntu-linux-18-sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.app_name}-${var.app_environment}-web-vm-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.linux_vm_hostname
    admin_username = var.linux_admin_user
    admin_password = var.linux_admin_password
    custom_data    = file("azure-user-data.sh")
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = var.app_environment
  }
}

#Output
output "external-ip-azure-web-server" {
  value = azurerm_public_ip.azure-web-ip.ip_address
}