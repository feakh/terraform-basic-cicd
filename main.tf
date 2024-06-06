resource "google_service_account" "service_account" {
  account_id   = "service-account-id"
  display_name = var.env
  project      = var.project_id
}

resource "google_service_account" "service_account2" {
  account_id   = "fe-may15-2024-dev-sa"
  display_name = "fe-may15-2024-dev-sad"
  project      = var.project_id
}

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


resource "google_compute_instance" "my-devops-instance" {
  count   = 2 # create 2 similar VM instances
  project = var.project_id
  boot_disk {
    auto_delete = true


    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240508"
      size  = 10
      type  = "pd-balanced"
    }

  }

  machine_type = "e2-micro"
  name         = "my-devops-instance-${count.index}"
  zone         = "us-central1-a"


  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    subnetwork = "projects/striped-reserve-419818/regions/us-central1/subnetworks/subnet1"
  }

  allow_stopping_for_update = true

  service_account {
    email  = google_service_account.service_account.email #"service-account-id@striped-reserve-419818.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    startup-script-url = "https://storage.googleapis.com/dev-may11-2024-fe/startup_file.txt"
  }
  # metadata_startup_script_url = "https://storage.googleapis.com/dev-may11-2024-fe/startup_file.txt"
}


resource "google_compute_firewall" "allow_ssh" {
  name    = "devopsgcp"
  network = "dev"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allowingressdevops"
  network = "dev"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"] # Example IP ranges
}



resource "google_storage_bucket_iam_binding" "binding" {
  bucket = google_storage_bucket.static.name
  role   = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}

# Define the unmanaged instance group
resource "google_compute_instance_group" "unmanaged_instance_group" {
  name        = "my-unmanaged-instance-group"
  description = "An unmanaged instance group with two instances"
  project     = var.project_id
  zone        = var.zone
  named_port {
    name = "http"
    port = "80"
  }
  #zone         = "us-central1-a"
  #instances = ["my-devops-instance-0", "my-devops-instance-1"]
  #instance_names = ["instance-1", "instance-2"]

  instances = [
    google_compute_instance.my-devops-instance[1].self_link
    #  google_compute_instance.my-devops-instance-1.instance.name,
  ]
}


# reserved IP address
resource "google_compute_global_address" "default" {
  name = "http-proxy-lb-ip"
  project     = var.project_id
}

  resource "google_compute_global_forwarding_rule" "default" {
  name                  = "http-content-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80-80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
  project     = var.project_id
}

resource "google_compute_target_http_proxy" "default" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.default.id
  project     = var.project_id
}

resource "google_compute_url_map" "default" {
  name            = "web-map-http"
  default_service = google_compute_backend_service.default.id
  project     = var.project_id
}


resource "google_compute_health_check" "tcp-health-check" {
  name    = "tcp-health-check"
  project = var.project_id

  timeout_sec         = 5
  check_interval_sec  = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  tcp_health_check {
    port = "80"
  }
}


resource "google_compute_backend_service" "default" {
  name          = "backend-service"
  project = var.project_id
  health_checks = [google_compute_health_check.tcp-health-check.id]
  protocol              = "HTTP"
  enable_cdn  = false
  timeout_sec = 30
  load_balancing_scheme = "EXTERNAL_MANAGED"


  backend {
    group = google_compute_instance_group.unmanaged_instance_group.self_link
    # group = resource_type.resource_name.attribute
  }

 }