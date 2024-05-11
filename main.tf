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


# resource "google_compute_instance" "default" {
#  name         = "my-devops-instance"
#  machine_type = "e2-medium"
#  zone         = "us-central1-a"

#  tags = ["ssh", "https"]

#  boot_disk {
#    initialize_params {
#      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240508"
#      size  = 10
#      type  = "pd-balanced"
#      }
#      labels = {
#        my_label = "value"
#      }  
# }
# }