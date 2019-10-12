variable "namespace" {}
variable "cassandra_name" {}
variable "cluster_size" {}
variable "storage_size" {}
variable "storage_class_name" {
  default = "standard"
}
