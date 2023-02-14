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

#(Start-Storage-bucket)

resource "google_storage_bucket" "app_bucket" {
  name     = var.storage_bucket_name
  location = var.region
}
#(END-Storage-bucket)

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

#(Start-CLoud-NAT)

resource "google_compute_router" "router" {
  name    = "app-nat-router"
  region  = google_compute_subnetwork.app_subnetwork.region
  network = google_compute_network.app_vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "app-nat-router"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

#(END-CLoud-NAT)


# #(Start load balancer)


# backend subnet
resource "google_compute_subnetwork" "default" {
  name          = "app-backend-subnet"
  ip_cidr_range = "10.24.6.0/24"
  network       = google_compute_network.app_vpc.id
}

# reserved IP address
resource "google_compute_global_address" "app_lb_static_ip_reserve" {
  name = "app-lb-static-ip-reserve"
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "app_lb_global_forwarding_rule" {
  name                  = "app-lb-global-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.app_lb_target_http_proxy.id
  ip_address            = google_compute_global_address.app_lb_static_ip_reserve.id
}

# http proxy
resource "google_compute_target_http_proxy" "app_lb_target_http_proxy" {
  name     = "app-lb-target-http-proxy"
  url_map  = google_compute_url_map.app_lb_url_map.id
}

# url map
resource "google_compute_url_map" "app_lb_url_map" {
  name            = "app-lb-url-map"
  default_service = google_compute_backend_service.app_lb_backend_service.id
}

# backend service with custom request and response headers
resource "google_compute_backend_service" "app_lb_backend_service" {
  name                     = "app-lb-backend-service"
  protocol                 = "HTTP"
  port_name                = "my-port"
  load_balancing_scheme    = "EXTERNAL"
  timeout_sec              = 10
  enable_cdn               = true
  custom_request_headers   = ["X-Client-Geo-Location: {client_region_subdivision}, {client_city}"]
  custom_response_headers  = ["X-Cache-Hit: {cdn_cache_status}"]
  health_checks            = [google_compute_health_check.app_lb_bookshel_hc.id]
  backend {
    group           = google_compute_instance_group_manager.app_bookshelf.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}



#(Start-Managed-Instance-Group)

#autoscaler-definition
resource "google_compute_autoscaler" "app_autoscaller" {
  name   = "app-autoscaller"
  zone   = var.zone
  target = google_compute_instance_group_manager.app_bookshelf.id

  autoscaling_policy {
    max_replicas    = 2
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.2
    }
  }
}
resource "google_compute_instance_group_manager" "app_bookshelf" {
  name        = "${var.app_name}-igm"
  description = "Terraform bookshelf instance group manager"
  base_instance_name = var.app_name
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.app_instance_template.id
    name              = "my_app_1"
  }

  target_size = 2

  named_port {
    name = "http"
    port = 8080
  }
}

# instance template
resource "google_compute_instance_template" "app_instance_template" {
  name_prefix  = "${var.app_name}-template-"
  machine_type = var.ins_template_machine_type
  tags         = ["allow-health-check", "allow-ssh"]

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.app_sa.email
    scopes = ["cloud-platform"]
  }
  network_interface {
    network    = google_compute_network.app_vpc.id
    subnetwork = google_compute_subnetwork.app_subnetwork.id
    access_config {
      # add external ip to fetch packages
    }
  }
  disk {
    source_image = "debian-cloud/debian-9"
    auto_delete  = true
    boot         = true
  }

  # install nginx and serve a simple web page
  metadata = {
    startup-script = <<-EOF1
      #! /bin/bash

      apt-get update
      apt install python3-pip -y
      pip3 install ansible==2.9.27
      sudo apt install git -y
      gcloud init
      cd /opt
      gcloud source repos clone Ansible --project=gcp-2021-3-bookshelf-sydor
      ansible-playbook  Ansible/main.yml --extra-vars \
        app_config.connection_name=google_sql_database_instance.app_sql_instance.connection_name \
        app_config.bucket${google_storage_bucket.app_bucket.name}


      # set -euo pipefail 

      # export DEBIAN_FRONTEND=noninteractive
      # apt-get update
      # apt-get install -y nginx-light jq

      # NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      # IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      # METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

      # cat <<EOF > /var/www/html/index.html
      # <pre>
      # Name: $NAME
      # IP: $IP
      # Metadata: $METADATA
      # </pre>
      # EOF
      
      #install git ansible
      #clone ansible repo
      #ansible-playbook playbook.yml --extra-vars ={}
      #
  
    EOF1
  }
  lifecycle {
   create_before_destroy = true
  }
}

# health check
resource "google_compute_health_check" "app_lb_bookshel_hc" {
  name     = "app-lb-bookshelf-hc"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}



# allow access from health check ranges
resource "google_compute_firewall" "default" {
  name          = "app-lb-fw-allow-hc"
  direction     = "INGRESS"
  network       = google_compute_network.app_vpc.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}

# allow SSH
resource "google_compute_firewall" "fw_lb_ssh" {
  name          = "app-lb-fw-ssh"
  direction     = "INGRESS"
  network       = google_compute_network.app_vpc.id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  source_tags = ["allow-ssh"]
  target_tags = ["allow-ssh"]
}

#(End-Managed-Instance-Group)


#(Start-instance-template-definition)





#(End-firewall-rules-definition)

#(END load balancer)



#mig and load balancer
#запустити апач 
#Cloud nat


# module "vpc" {
#   source = "../modules/vpc"
# }
