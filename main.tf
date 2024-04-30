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