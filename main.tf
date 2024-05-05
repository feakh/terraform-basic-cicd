resource "google_service_account" "service_account" {
  account_id   = "service-account-id"
  display_name = var.env
  project      = var.project_id
}
# comment
resource "google_compute_network" "custom-test" {
  name                    = var.env
  auto_create_subnetworks = false
  project                 = var.project_id
}
resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  display_name  = var.env
  project       = var.project_id
  network       = google_compute_network.custom-test.id #returns the id of vpc created in line 7
}

resource "google_storage_bucket" "static" {
  name                        = "fe-may-1-2024-bucket"
  location                    = "US"
  storage_class               = "STANDARD"
  project                     = var.project_id
  uniform_bucket_level_access = true
}
