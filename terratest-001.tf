module "terratest-001" {
  source = "./modules"
  hostname = "terratest-001"
  resource_group_name = "terraform-test1"
  subnet_name = "vnet2-subnet1"
  IPAddress = "172.168.160.25"
  vmsize = "Standard_B2s"
  managed_disk_type = "StandardSSD_LRS"
}