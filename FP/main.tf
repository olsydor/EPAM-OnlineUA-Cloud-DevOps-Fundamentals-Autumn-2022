provider "google" {
  credentials = file("epam-autumn-2022-fp-5eefb5cd8418.json")
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

 resource "google_compute_address" "static_ip" {
  name = "static-ip"
}

# Create firewall rule for SSH
resource "google_compute_firewall" "power-app-allow-ssh" {
  name    = "${var.app_name}-allow-ssh"
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
  name    = "${var.app_name}-allow-http"
  network = google_compute_network.power-app-vpc.self_link
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}
# (End-VPC-definition)

#(Start-instance with Debian 10 and Jenkins in a Docker container)
resource "google_compute_instance" "final-project" {
  name         = var.app_name
  machine_type = var.ins_template_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.vm_instance_image_name
    }
  }

  network_interface {
    network    = google_compute_network.power-app-vpc.self_link #google_compute_network.power-app-vpc.id
    subnetwork = var.subnet_name
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
    docker run -d -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts
  EOF
    #from startup script jenkins/jenkins:lts
  metadata = {
    ssh-keys = "olsydorsb:${file("~/.ssh/id_rsa.pub")}"
  }

  tags = ["http-server", "ssh"]
}
/*
resource "google_compute_global_address" "final_project" {
  name         = "final-project-global-psconnect-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  network      = google_compute_network.power-app-vpc.id
  address      = "100.100.100.105"
}
*/