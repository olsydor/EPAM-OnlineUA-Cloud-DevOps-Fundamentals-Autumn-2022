# export GOOGLE_CLOUD_KEYFILE_JSON="/media/olsydor/data/study/EPAM2223/epam-autumn-2022-fp-5eefb5cd8418.json"
# locals {
#   project = "gcp-2021-3-bookshelf-sydor"
#   region  = "europe-central2"
#   zone    = "europe-central2-a"
#}

provider "google" {
  credentials = file("/epam-autumn-2022-fp-5eefb5cd8418.json")
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}
# (Start-VPC-definition)
resource "google_compute_network" "power-app-vpc" {
  project                 = var.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "power-app-eu-central2" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_range
  region        = var.region
  network       = google_compute_network.power-app-vpc.id
}

# Create firewall rule for SSH
resource "google_compute_firewall" "power-app-allow-ssh" {
  name    = "power-app-allow-ssh"
  network = google_compute_network.power-app-vpc.self_link
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

# Create firewall rule for HTTP
resource "google_compute_firewall" "power-app-allow-http" {
  name    = "power-app-allow-http"
  network = google_compute_network.power-app-vpc.self_link
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http"]
}
# (End-VPC-definition)

#(Start-service-account)
#resource "google_service_account" "power-app_sa" {

  #account_id   = var.service_account_id
  #role = "roles/compute.networks.create"
  #display_name = "bucket-writer-sa "
#}

  #resource "google_project_iam_member" "role_binding" {
    #project = var.project_id
    #role    = "roles/editor"
    #member  = "serviceAccount:${google_service_account.power-app-sa.email}"
  #}
#(END-service-account)

#(Start-instance with Debian 10 and Jenkins in a Docker container)
resource "google_compute_instance" "app_name" {
  name         = var.app_name
  machine_type = var.ins_template_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.vm_instance_image_name
    }
  }

  network_interface {
    network = google_compute_network.power-app-vpc.self_link #google_compute_network.power-app-vpc.id
    subnetwork = var.subnet_name
  }

  metadata_startup_script = "docker run -d -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts"

  tags = ["http-server", "https-server"]
}
#(END instance with Debian 10 and Jenkins in a Docker container)