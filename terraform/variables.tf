variable "location" {
  type        = string
  default     = "canadacentral" # Toronto-friendly region
  description = "Azure region for all resources"
}

# Lock RDP to your IP (recommended). Replace with "x.x.x.x/32".
variable "rdp_source" {
  type        = string
  default     = "0.0.0.0/0" # Open to world (NOT for production)
  description = "CIDR allowed to RDP (3389) into the VM"
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
  description = "Admin username for the Windows VM"
}
