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



# resource "google_compute_instance" "my-devops-instance2" {
#  count = 2 # create 2 similar VM instances
#  project = var.project_id
#  boot_disk {
#    auto_delete = true


#    initialize_params {
#      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240508"
#      size  = 10
#      type  = "pd-balanced"
#    }

#  }

#  machine_type = "e2-micro"
#  name         = "my-devops-instance2-${count.index}"
#  zone         = "us-central1-a"


#  network_interface {
#    access_config {
#      network_tier = "PREMIUM"
#    }

#    subnetwork = "projects/striped-reserve-419818/regions/us-central1/subnetworks/subnet1"
#  }

#  allow_stopping_for_update = true

#  service_account {
#    email  = google_service_account.service_account.email #"service-account-id@striped-reserve-419818.iam.gserviceaccount.com"
#    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
#  }

#  metadata = {
#    startup-script-url = "https://storage.googleapis.com/dev-may11-2024-fe/startup_file.txt"
#  }
# metadata_startup_script_url = "https://storage.googleapis.com/dev-may11-2024-fe/startup_file.txt"
# }

# Define the unmanaged instance group
resource "google_compute_instance_group" "unmanaged_instance_group" {
  name        = "my-unmanaged-instance-group"
  description = "An unmanaged instance group with two instances"
  project     = var.project_id
  zone        = var.zone
  #zone         = "us-central1-a"
  #instances = ["my-devops-instance-0", "my-devops-instance-1"]
  #instance_names = ["instance-1", "instance-2"]

  instances = [
    google_compute_instance.my-devops-instance[0].self_link,
    google_compute_instance.my-devops-instance[1].self_link
    #  google_compute_instance.my-devops-instance-1.instance.name,
  ]

  #instances = [
  #  "projects/striped-reserve-419818/zones/us-central1-a/instances/my-devops-instance-0",
  #  "projects/striped-reserve-419818/zones/us-central1-a/instances/my-devops-instance-1",
  #]
}
#resource "google_compute_instance" "my-devops-instance" {
#  count = 2 # create 2 similar VM instances

# type.name.attribute


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
  health_checks = [google_compute_http_health_check.default.id]
  protocol              = "HTTP"
  enable_cdn  = false
  timeout_sec = 30
  load_balancing_scheme = "EXTERNAL_MANAGED"
  

#  name                  = "tf-test-backend-service-external"
#  protocol              = "HTTP"
#  load_balancing_scheme = "EXTERNAL"
#  iap {
#    oauth2_client_id     = "abc"
#    oauth2_client_secret = "xyz"


#  health_checks = [google_compute_http_health_check.default.id]
#  enable_cdn  = true
#  cdn_policy {
#    signed_url_cache_max_age_sec = 7200

#  name          = "backend-service"
#  enable_cdn  = true
#  cdn_policy {
#    cache_mode = "USE_ORIGIN_HEADERS"
#    cache_key_policy {
#      include_host = true
#      include_protocol = true
#      include_query_string = true
#      include_http_headers = ["X-My-Header-Field"]

#    name          = "backend-service"
#  enable_cdn  = true
#  cdn_policy {
#    cache_mode = "CACHE_ALL_STATIC"
#    default_ttl = 3600
#    client_ttl  = 7200
#    max_ttl     = 10800
#    cache_key_policy {
#      include_host = true
#      include_protocol = true
#      include_query_string = true
#      include_named_cookies = ["__next_preview_data", "__prerender_bypass"]

    name          = "backend-service"
    capacity_Scaler = 1
      group = "projects/striped-reserve-419818/zones/us-central1-a/instanceGroups/instance-group-1"
      balancing_Mode = UTILIZATION
      max_Utilization = 0.8
      port_Name = http
  timeout_Sec = 30
  locality_Lb_Policy = "ROUND_ROBIN",
  selfLink = "projects/striped-reserve-419818/global/backendServices/backendservfe
  ipAddress_Selection_Policy = IPV4_ONLY
  protocol = HTTP


resource "google_compute_http_health_check" "default" {
  name               = "health-check"
  project = var.project_id
  request_path       = "/"
  check_interval_sec = 5
  timeout_sec        = 5
}


#"description": "",
#  "sessionAffinity": "NONE",
#  "loadBalancingScheme": "EXTERNAL_MANAGED",
#  "healthChecks": [
#    "projects/striped-reserve-419818/global/healthChecks/healthcheckfe"
#  ],
#  "enableCDN": false,
 # "name": "backendservfe",
 # "connectionDraining": {
 #   "drainingTimeoutSec": 300
 # },
 # "logConfig": {
 #   "enable": false
  
  