#resource "google_service_account" "service_account" {
#  account_id   = "service-account-id"
#  display_name = var.env
#  project      = var.project_id
#}
# comment
#resource "google_compute_network" "custom-test" {
#  name                    = var.env
#  auto_create_subnetworks = false
#  project                 = var.project_id
#}
#resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
#  name          = var.env
#  ip_cidr_range = "10.2.0.0/16"
#  region        = var.region
#  project       = var.project_id
#  network       = google_compute_network.custom-test.id #returns the id of vpc created in line 7
#}

resource "google_compute_network" "custom-test" {
  name                    = var.env
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  for_each      = var.subnetwork_map
  name          = each.key
  ip_cidr_range = each.value
  region        = var.region
  project       = var.project_id
  network       = google_compute_network.custom-test.id #returns the id of vpc created in line 7
}

# resource "google_storage_bucket" "static" {
# for_each                    = toset(var.bucket_names)
#  name                        = each.key
#  location                    = each.key == "ta-mya8-2024-prd" ? "EU" : "US"
#  storage_class               = "STANDARD"
#  project                     = var.project_id
#  uniform_bucket_level_access = true
#}

# resource "google_storage_bucket" "stable" {
#  for_each                    = var.bucket_map
#  name                        = each.key
#  location                    = each.value
#  storage_class               = "STANDARD"
#  project                     = var.project_id
#  uniform_bucket_level_access = true
# }

resource "google_storage_bucket" "static" {
  name                        = var.bucket_names
  location                    = "US"
  storage_class               = "STANDARD"
  project                     = var.project_id
  uniform_bucket_level_access = true
}

# Upload a text file as an object
# to the storage bucket
resource "google_storage_bucket_object" "default" {
  name         = "startup_file.txt"
  source       = "startup.sh"
  content_type = "text/plain"
  bucket       = google_storage_bucket.static.id
}

# resource "google_storage_bucket" "static_loop" {
# name                        = "${var.env}-fe-ma4-2024-2"
# location                    = "US"
# storage_class               = "STANDARD"
# project                     = var.project_id
# uniform_bucket_level_access = true
# }
# terraform deployment of vpc and buckets

# provider "google" {
#  project = var.project_id
#  region  = var.region
# }

resource "google_compute_instance" "my-devops-instance" {
  project = var.project_id
  boot_disk {
    auto_delete = true
    #    device_name = "my-devops-instance"


    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240508"
      size  = 10
      type  = "pd-balanced"
    }

    #    mode = "READ_WRITE"
  }

  #  can_ip_forward      = false
  #  deletion_protection = false
  #  enable_display      = false

  #  labels = {
  #    goog-ec-src = "vm_add-tf"
  #  }

  machine_type = "e2-micro"
  name         = "my-devops-instance"
  zone         = "us-central1-a"

  network_interface {
    access_config {
      network_tier = "STANDARD"
    }

    nic_type    = "VIRTIO_NET"
    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/striped-reserve-419818/regions/us-central1/subnetworks/subnet1"
  }

  allow_stopping_for_update = true

  #  scheduling {
  #    automatic_restart   = true
  #    on_host_maintenance = "MIGRATE"
  #    preemptible         = false
  #    provisioning_model  = "STANDARD"
  #  }

  #  service_account {
  #    email  = "235737959051-compute@developer.gserviceaccount.com"
  #    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  #  }

  #  shielded_instance_config {
  #    enable_integrity_monitoring = true
  #    enable_secure_boot          = false
  #    enable_vtpm                 = true
  #  }

  #  zone = "us-central1-a"
}
