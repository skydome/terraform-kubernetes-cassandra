# terraform-kubernetes-cassandra
Cassandra on Kubernetes

Tested on GKE but it should work for any kubernetes cluster given the right terraform-provider-kubernetes setup.

## Inputs

- **cassandra_name**         : name of the cassandra deployment
- **namespace**              : kubernetes namespace to be deployed
- **cluster_size**           : replica instance count
- **storage_size**           : cassandra storage size (e.g "10Gi")
- **storage_class_name**     : kubernetes storage class name (default: "standard")

## Dependencies

Terraform Kubernetes Provider

## Tested With

- terraform-providers/kubernetes : 1.9.0
- cassandra:3.11.3 docker image
- kubernetes 1.13.7-gke.8

## Credits

This module was initially generated from helm/incubator/cassandra via [k2tf](https://github.com/sl1pm4t/k2tf) project.
