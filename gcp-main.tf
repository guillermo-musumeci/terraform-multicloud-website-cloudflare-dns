# gcp-main.tf | Define GCP Provider, VPC, Subnet, Security Groups, Computer Instance

# Setup the GCP provider
terraform {
  required_version = ">= 0.12"
}

provider "google" {
  project     = var.gcp_project
  credentials = file(var.gcp_auth_file)
  region      = var.gcp_region
  zone        = var.gcp_zone
}

# Create VPC
resource "google_compute_network" "gcp-vpc" {
  name                    = "${var.app_name}-${var.app_environment}-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

# Create subnet
resource "google_compute_subnetwork" "gcp-subnet" {
  name          = "${var.app_name}-${var.app_environment}-subnet"
  ip_cidr_range = var.gcp_subnet_cidr
  network       = google_compute_network.gcp-vpc.name
  region        = var.gcp_region
}

# Firewall allow http
resource "google_compute_firewall" "gcp-allow-http" {
  name    = "${var.app_name}-${var.app_environment}-fw-allow-http"
  network = google_compute_network.gcp-vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http"] 
}

# Firewall allow ssh
resource "google_compute_firewall" "gcp-allow-ssh" {
  name    = "${var.app_name}-${var.app_environment}-fw-allow-ssh"
  network = google_compute_network.gcp-vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh"]
}

# Create a public ip for web server
resource "google_compute_address" "gcp-web-ip" {
  name    = "${var.app_name}-${var.app_environment}-web-ip"
  project = var.gcp_project
  region  = var.gcp_region
}

# Define bootstrap file
data "template_file" "metadata_startup_script" {
    template = file("gcp-user-data.sh")
}

# Create VM for web server
resource "google_compute_instance" "gpc-web-server" {
  name         = "${var.app_name}-${var.app_environment}-web-server"
  machine_type = "f1-micro"
  zone         = var.gcp_zone
  tags         = ["ssh","http"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  metadata_startup_script = data.template_file.metadata_startup_script.rendered

  network_interface {
    network    = google_compute_network.gcp-vpc.name
    subnetwork = google_compute_subnetwork.gcp-subnet.name
    access_config {
      nat_ip = google_compute_address.gcp-web-ip.address
    }
  }
}

# Output
output "external-ip-gcp-web-server" {
  value = google_compute_address.gcp-web-ip.address
}