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

variable "bucket_names" {
  type        = list(string)
  description = "names of the buckets to be created"
}