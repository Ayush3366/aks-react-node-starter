########################################
# Resources only (no providers/outputs here)
########################################

# Strong random password for the VM
resource "random_password" "admin" {
  length           = 20
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "ayush-rg"
  location = var.location
  tags     = { env = "demo" }
}

# Networking
resource "azurerm_virtual_network" "vnet" {
  name                = "ayush-rg-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = { env = "demo" }
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ✅ Standard (Static) IPv4 Public IP — fixes "Basic SKU" limit error
resource "azurerm_public_ip" "pip" {
  name                = "ayush-win-vm-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku               = "Standard" # <- key change
  allocation_method = "Static"   # <- required for Standard
  ip_version        = "IPv4"

  tags = { env = "demo" }
}

# NSG with an RDP rule (tighten source for security)
resource "azurerm_network_security_group" "nsg" {
  name                = "ayush-win-vm-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-RDP-3389"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.rdp_source
    destination_address_prefix = "*"
  }

  tags = { env = "demo" }
}

resource "azurerm_network_interface" "nic" {
  name                = "ayush-win-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  tags = { env = "demo" }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Windows VM
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "ayush-win-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B2s" # economical size

  admin_username = var.admin_username
  admin_password = random_password.admin.result

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    name                 = "ayush-win-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  tags = { env = "demo" }
}
