# export GOOGLE_CLOUD_KEYFILE_JSON="../../bookshelf-creds.json"
# locals {
#   project = "gcp-2021-3-bookshelf-sydor"
#   region  = "europe-central2"
#   zone    = "europe-central2-a"
#}

provider "google" {
  # credentials = file("../bookshelf-creds.json")
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}
# (Start-VPC-definition)
resource "google_compute_network" "app_vpc" {
  project                 = var.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = false
  mtu                     = 1460
}
resource "google_compute_subnetwork" "app_subnetwork" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_range
  region        = var.region
  network       = google_compute_network.app_vpc.id

}
# (End-VPC-definition)

#(Start-service-account)
resource "google_service_account" "app_sa" {
  account_id   = var.service_account_id
  display_name = "app-sa-tf"
}

resource "google_project_iam_member" "role_binding" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}
#(END-service-account)
