variable "project_id" {
  type        = string
  description = "project id"
}

variable "env" {
  type        = string
  description = "name of the environment"

}

variable "region" {
  type        = string
  description = "name of region"
}

# variable "zone" {
#  type        = string
#  description = "name of zone"
# }

# variable "bucket_objects" {
#  type        = list(string)
#  description = "objects inside the buckets to be created"
# }

variable "bucket_names" {
  type        = string
  description = "names of the buckets to be created"
}

variable "location" {
  type        = list(string)
  description = "names of locations"
}

variable "bucket_map" {
  type        = map(string)
  description = "map name = location"
}

variable "subnetwork_map" {
  type        = map(string)
  description = "map name = ip_cidr_range"
}
