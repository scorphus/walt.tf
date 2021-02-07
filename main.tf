# This file is part of walt.tf
# https://github.com/scorphus/walt.tf

# Based off the following sample:
# https://github.com/aiven/terraform-provider-aiven/blob/master/sample.tf

# Licensed under the BSD-3-Clause license:
# https://opensource.org/licenses/BSD-3-Clause
# Copyright (c) 2021, Pablo S. Blum de Aguiar <scorphus@gmail.com>

terraform {
  required_providers {
    aiven = {
      source  = "aiven/aiven"
      version = "2.1.6"
    }
  }
}

provider "aiven" {
  api_token = var.aiven_api_token
}

resource "aiven_project" "project" {
  project = var.aiven_project
}

# Kafka service
resource "aiven_service" "kafka_service" {
  project                 = aiven_project.project.project
  cloud_name              = var.cloud_name
  plan                    = "startup-2"
  service_name            = var.kafka_service
  service_type            = "kafka"
  maintenance_window_dow  = "monday"
  maintenance_window_time = "10:00:00"
  kafka_user_config {
    kafka_version = "2.7"
    kafka {
      group_max_session_timeout_ms = 70000
      log_retention_bytes          = 1000000000
    }
  }
}

# Topic for Kafka
resource "aiven_kafka_topic" "kafka_topic" {
  project      = aiven_project.project.project
  service_name = aiven_service.kafka_service.service_name
  replication  = 2
  partitions   = 3
  topic_name   = "walt"
  config {
    retention_bytes = 1000000000
  }
}

# User for Kafka
resource "aiven_service_user" "kafka_user" {
  project      = aiven_project.project.project
  service_name = aiven_service.kafka_service.service_name
  username     = "user_kafka_walt"
}

# ACL for Kafka
resource "aiven_kafka_acl" "kafka_acl" {
  project      = aiven_project.project.project
  service_name = aiven_service.kafka_service.service_name
  topic        = aiven_kafka_topic.kafka_topic.topic_name
  username     = aiven_service_user.kafka_user.username
  permission   = "admin"
}

# PostreSQL service
resource "aiven_service" "postgres_service" {
  project                 = aiven_project.project.project
  cloud_name              = var.cloud_name
  plan                    = "hobbyist"
  service_name            = var.postgres_service
  service_type            = "pg"
  maintenance_window_dow  = "monday"
  maintenance_window_time = "12:00:00"
  pg_user_config {
    pg {
      idle_in_transaction_session_timeout = 900
    }
    pg_version = "12"
  }
}

# PostgreSQL database
resource "aiven_database" "postgres_database" {
  project       = aiven_project.project.project
  service_name  = aiven_service.postgres_service.service_name
  database_name = "walt"
}

# PostgreSQL user
resource "aiven_service_user" "postgres_user" {
  project      = aiven_project.project.project
  service_name = aiven_service.postgres_service.service_name
  username     = "user_pg_walt"
}
