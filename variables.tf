# This file is part of walt.tf
# https://github.com/scorphus/walt.tf

# Licensed under the BSD-3-Clause license:
# https://opensource.org/licenses/BSD-3-Clause
# Copyright (c) 2021, Pablo S. Blum de Aguiar <scorphus@gmail.com>

variable "aiven_api_token" {
  type    = string
  default = "AIVEN_API_TOKEN" # Set this value accordingly
}

variable "aiven_project" {
  type    = string
  default = "AIVEN_PROJECT" # Set this value accordingly
}

variable "cloud_name" {
  type    = string
  default = "CLOUD_NAME" # Set this value accordingly
}

variable "kafka_service" {
  type    = string
  default = "walt-kafka"
}

variable "postgres_service" {
  type    = string
  default = "walt-postgres"
}
