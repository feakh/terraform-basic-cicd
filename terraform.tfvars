project_id   = "striped-reserve-419818"
env          = "dev"
region       = "us-east4"
# bucket_names = ["fe-may8-2024-dev", "tst-may8-2024-ra", "ta-mya8-2024-prd"]
bucket_names = "dev-may11-2024.fe"
bucket_objects = "startup_file.txt"
location     = ["US", "EU"]
bucket_map = {
  may9-2024-fe-ma-test = "US"
  fe-pa-may9-2024-test = "EU"
}

subnetwork_map = {
# name = cidr_range
# key = "value"
  subnet1 = "10.20.30.0/24"
  subnet2 = "10.20.33.0/24"
  subnet3 = "10.20.36.0/24"
}