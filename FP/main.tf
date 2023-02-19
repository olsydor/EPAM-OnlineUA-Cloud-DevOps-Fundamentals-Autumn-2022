# export GOOGLE_CLOUD_KEYFILE_JSON="/media/olsydor/data/study/EPAM2223/epam-autumn-2022-fp-5eefb5cd8418.json"
# locals {
#   project = "gcp-2021-3-bookshelf-sydor"
#   region  = "europe-central2"
#   zone    = "europe-central2-a"
#}

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
  target_tags   = ["http"]
}
# (End-VPC-definition)

#(Start-instance with Debian 10 and Jenkins in a Docker container)
#resource "google_compute_instance" "app_name" {
#  name         = var.app_name
#  machine_type = var.ins_template_machine_type
#  zone         = var.zone

#  boot_disk {
#    initialize_params {
#      image = var.vm_instance_image_name
#    }
#  }
#
#  network_interface {
#    network = google_compute_network.power-app-vpc.self_link #google_compute_network.power-app-vpc.id
#    subnetwork = var.subnet_name
#  }

#  metadata_startup_script = "docker run -d -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts"

#  tags = ["http-server", "https-server"]
#}

resource "google_compute_address" "app_name" {
  name = "${var.app_name}-ip"
}

# reserved IP address
resource "google_compute_global_address" "app_lb_static_ip_reserve" {
  name = "app-lb-static-ip-reserve"
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "app_lb_global_forwarding_rule" {
  name                  = "${var.app_name}-global-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "8080"
  target                = google_compute_target_http_proxy.app_lb_target_http_proxy.id
  ip_address            = google_compute_global_address.app_lb_static_ip_reserve.id
}

resource "google_compute_target_http_proxy" "app_lb_target_http_proxy" {
  name     = "app-lb-target-http-proxy"
  url_map  = google_compute_url_map.app_lb_url_map.id
}

# url map
resource "google_compute_url_map" "app_lb_url_map" {
  name            = "app-lb-url-map"
  default_service = google_compute_backend_service.final_project_backend_service.id
}

# backend service with custom request and response headers
resource "google_compute_backend_service" "final_project_backend_service" {
  name                     = "${var.app_name}-lb-backend-service"
  protocol                 = "HTTP"
  port_name                = "http"
  load_balancing_scheme    = "EXTERNAL"
  timeout_sec              = 10
  health_checks            = [google_compute_http_health_check.final_project_hc.id]
  backend {
    group           = google_compute_instance_group_manager.final-project.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0

  }
}

resource "google_compute_instance_group_manager" "final-project" {
  name        = "${var.app_name}-igm"
  description = "Terraform bookshelf instance group manager"
  base_instance_name = var.app_name
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.final_project_instance_template.id
    name              = "my_app_1"
  }

  target_size = 2

  named_port {
    name = "http"
    port = 8080
   }
}

# health check
resource "google_compute_http_health_check" "final_project_hc" {
  name               = var.app_name
  port               = "8080"
  check_interval_sec = 5
  timeout_sec        = 5
}
resource "google_compute_instance_template" "final_project_instance_template" {
  name_prefix  = "${var.app_name}-template-"
  machine_type = var.ins_template_machine_type
  #tags         = ["allow-health-check", "allow-ssh"]

  /*
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.app_sa.email
    scopes = ["cloud-platform"]
  } */
  network_interface {
    network    = google_compute_network.power-app-vpc.id
    subnetwork = google_compute_subnetwork.power-app-eu-central2.id
    access_config {
      # add external ip to fetch packages
    }
  }
  disk {
    source_image = var.vm_instance_image_name
    auto_delete  = true
    boot         = true
  }
  metadata_startup_script = "docker run -d -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts"

  tags = ["http-server", "https-server"]
 }


#resource "google_compute_forwarding_rule" "final-project" {
#  name       = "${var.app_name}-forwarding-rule"
#  ip_address = google_compute_address.app_name.address
#  port_range = "8080-8080"
#
#  load_balancing_scheme = "EXTERNAL"
#  network_tier          = "PREMIUM"
#
#  backend_service = google_compute_backend_service.app_name.self_link
#}

/*resource "google_compute_backend_service" "final-project" {
  name = "${var.app_name}-backend-service"

  backend {
    group = google_compute_instance_group.final-project.self_link
  }

  health_checks = ["${google_compute_http_health_check.app_name.self_link}"]
}

resource "google_compute_http_health_check" "app_name" {
  name               = var.app_name
  port               = "8080"
  check_interval_sec = 5
  timeout_sec        = 5
}

resource "google_compute_instance_group" "final-project" {
  name        = var.app_name
  description = "Instance group for Jenkins"

  named_port {
    name = var.app_name
    port = 8080
  }

  instances = [google_compute_instance.final-project.self_link]

  named_port {
    name = var.app_name
    port = 8080
  }
}

resource "google_compute_firewall" "power-app-allow-tcp" {
  name          = "${var.app_name}-firewall"
  network       = google_compute_network.power-app-vpc.id

  allow {
    protocol = "tcp"
    ports    = ["8080", "50000"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["http-server", "https-server"]
}
*/
#(END instance with Debian 10 and Jenkins in a Docker container)