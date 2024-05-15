resource "google_service_account" "service_account" {
  account_id   = "service-account-id"
  display_name = var.env
  project      = var.project_id
}
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


    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240508"
      size  = 10
      type  = "pd-balanced"
    }

  }

  machine_type = "e2-micro"
  name         = "my-devops-instance"
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

# metadata_startup_script = "gsutil cp gs://dev-may11-2024-fe/startup_file.txt /path/to/script.sh && chmod +x /path/to/script.sh && /path/to/script.sh"

# #! /bin/bash
# apt update
# apt -y install apache2
# cat <<EOF > /var/www/html/index.html
# <html><body><p>Linux startup script from Cloud Storage.</p></body></html>
# EOF

#resource "google_compute_firewall" "rules" {
#  project     = "My First Project"
#  name        = "allowingressdevops"
#  network     = "dev"
#  description = "Creates firewall rule targeting all instances"

#  allow {
#    protocol  = "tcp"
#    ports     = ["80"]
#  }
#
#  source_tags = ["foo"]
#  target_tags = ["web"]
# }

#resource "google_compute_firewall" "rules" {
#  project     = "My First Project"
#  name        = "devopsgcp"
#  network     = "dev"
#  description = "Creates firewall rule targeting all instances"

#  allow {
#    protocol  = "tcp"
#    ports     = ["22"]
#  }
#
#  source_tags = ["foo"]
#  target_tags = ["web"]
# }


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
