variable "project_id" {
  default = "epam-autumn-2022-fp "
}
variable "region" {
  default = "europe-central2"
}
variable "zone" {
  default = "europe-central2-a"
}

#(Network)
variable "vpc_name" {
  default = "app-vpc"
}

variable "subnet_name" {
  default = "europe-central2-subnet"
}
variable "subnet_range" {
  default = "10.24.5.0/24"
}
#(Network)

#(Virtual machine)
variable "app_name" {
  default = "Final-project"
}
variable "ins_template_machine_type" {
  default = "e2-small"
}
variable "vm_instance_image_name" {
  default = "debian-cloud/debian-9"
}
#(Virtual machine)

#(Service account)
variable "service_account_id" {
  default = "tf-automation"
}
#(Service account)