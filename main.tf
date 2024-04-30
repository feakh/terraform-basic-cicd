resource "google_service_account" "service_account" {
  account_id   = "service-account-id"
  display_name = "devopscoolgirl"
  project      = "striped-reserve-419818"
}
# comment
resource "google_compute_network" "custom-test" {
  name                    = "test-network"
  auto_create_subnetworks = false
  project      = "striped-reserve-419818"
}
resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  project      = "striped-reserve-419818"
  network       = google_compute_network.custom-test.id#returns the id of vpc created in line 7
}