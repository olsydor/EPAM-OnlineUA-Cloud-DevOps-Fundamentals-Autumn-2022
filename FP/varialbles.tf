variable "project_id" {
  default = "gcp-2021-3-bookshelf-sydor"
}
variable "region" {
  default = "europe-central2"
}
variable "zone" {
  default = "europe-central2-a"
}
#(Database)
variable "db_name" {
  default = "app-bookshelf"
}
variable "db_instance" {
  default = "app-bookshelf"
}
variable "db_version" {
  default = "MYSQL_5_7"
}
variable "db_instance_tier" {
  default = "db-g1-small"
}
#(Database)

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
  default = "bookshelf-olsydor"
}
variable "ins_template_machine_type" {
  default = "e2-small"
}
variable "vm_instance_image_name" {
  default = "debian-cloud/debian-9"
}
#(Virtual machine)

#(Storage bucket)
variable "storage_bucket_name" {
  default = "tf_bookshelf"
}
#(Storage bucket)

#(Service account)
variable "service_account_id" {
  default = "tf-automation"
}
#(Service account)