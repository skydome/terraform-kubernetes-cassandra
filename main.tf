resource "kubernetes_service" "cassandra" {
  metadata {
    name   = "${var.cassandra_name}"
    namespace = "${var.namespace}"
    labels = { app = "${var.cassandra_name}"}
  }
  spec {
    port {
      name        = "intra"
      port        = 7000
      target_port = "7000"
    }
    port {
      name        = "tls"
      port        = 7001
      target_port = "7001"
    }
    port {
      name        = "jmx"
      port        = 7199
      target_port = "7199"
    }
    port {
      name        = "cql"
      port        = 9042
      target_port = "9042"
    }
    port {
      name        = "thrift"
      port        = 9160
      target_port = "9160"
    }
    selector   = { app = "${var.cassandra_name}"}
    cluster_ip = "None"
    type       = "ClusterIP"
  }
}

resource "kubernetes_stateful_set" "cassandra" {
  metadata {
    name   = "${var.cassandra_name}"
    namespace = "${var.namespace}"
    labels = { app = "${var.cassandra_name}" }
  }
  spec {
    replicas = "${var.cluster_size}"
    selector {
      match_labels = { app = "${var.cassandra_name}"}
    }
    template {
      metadata {
        labels = { app = "${var.cassandra_name}" }
      }
      spec {
        container {
          name  = "${var.cassandra_name}"
          image = "cassandra:3.11.3"
          port {
            name           = "intra"
            container_port = 7000
          }
          port {
            name           = "tls"
            container_port = 7001
          }
          port {
            name           = "jmx"
            container_port = 7199
          }
          port {
            name           = "cql"
            container_port = 9042
          }
          port {
            name           = "thrift"
            container_port = 9160
          }
          env {
            name  = "CASSANDRA_SEEDS"
            value = "${var.cassandra_name}-0.${var.cassandra_name}.${var.namespace}.svc.cluster.local,${var.cassandra_name}-1.${var.cassandra_name}.${var.namespace}.svc.cluster.local"
          }
          env {
            name  = "MAX_HEAP_SIZE"
            value = "2048M"
          }
          env {
            name  = "HEAP_NEWSIZE"
            value = "512M"
          }
          env {
            name  = "CASSANDRA_ENDPOINT_SNITCH"
            value = "SimpleSnitch"
          }
          env {
            name  = "CASSANDRA_CLUSTER_NAME"
            value = "cassandra"
          }
          env {
            name  = "CASSANDRA_DC"
            value = "DC1"
          }
          env {
            name  = "CASSANDRA_RACK"
            value = "RAC1"
          }
          env {
            name  = "CASSANDRA_START_RPC"
            value = "false"
          }
          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }
          volume_mount {
            name       = "data"
            mount_path = "/var/lib/cassandra"
          }
          liveness_probe {
            exec {
              command = ["/bin/sh", "-c", "nodetool status"]
            }
            initial_delay_seconds = 90
            timeout_seconds       = 5
            period_seconds        = 30
            success_threshold     = 1
            failure_threshold     = 3
          }
          readiness_probe {
            exec {
              command = ["/bin/sh", "-c", "nodetool status | grep -E \"^UN\\s+$${POD_IP}\""]
            }
            initial_delay_seconds = 90
            timeout_seconds       = 5
            period_seconds        = 30
            success_threshold     = 1
            failure_threshold     = 3
          }
          image_pull_policy = "IfNotPresent"
        }
        termination_grace_period_seconds = 30
      }
    }
    volume_claim_template {
      metadata {
        name   = "data"
        labels = { app = "${var.cassandra_name}" }
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        storage_class_name = "generic"
        resources {
          requests = { storage = ${var.storage_size} }
        }
      }
    }
    service_name          = "${var.cassandra_name}"
    pod_management_policy = "OrderedReady"
    update_strategy {
      type = "OnDelete"
    }
  }
}

