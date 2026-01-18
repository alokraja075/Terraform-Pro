module "azure_vm" {
  source = "../../modules/vm"

  resource_group_name = var.resource_group_name
  location            = var.location
  vm_name             = var.vm_name
  vm_size             = var.vm_size
  os_type             = var.os_type
  
  image_publisher = var.image_publisher
  image_offer     = var.image_offer
  image_sku       = var.image_sku
  image_version   = var.image_version
  
  admin_username = var.admin_username
  admin_password = var.admin_password
  ssh_public_key = var.ssh_public_key
  
  subnet_id               = var.subnet_id
  create_public_ip        = var.create_public_ip
  private_ip_allocation   = var.private_ip_allocation
  
  security_rules = var.security_rules
  
  enable_monitoring     = var.enable_monitoring
  log_retention_days    = var.log_retention_days
  
  tags = var.tags
}
