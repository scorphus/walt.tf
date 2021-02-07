# This file is part of walt.tf
# https://github.com/scorphus/walt.tf

# Licensed under the BSD-3-Clause license:
# https://opensource.org/licenses/BSD-3-Clause
# Copyright (c) 2021, Pablo S. Blum de Aguiar <scorphus@gmail.com>

# list all available targets
list:
	@sh -c "$(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep -v 'make\[1\]' | grep -v 'Makefile' | sort"
.PHONY: list
# required for list
no_targets__:

all: assert-requirements install-walt terraform-apply generate-certs generate-config create-tables
	@echo "You should be ready to run walt to produce/consume results!"
.PHONY: all

# assert requirements are available
assert-requirements:
	@echo "Verifying requirements availability..."
	@type pip > /dev/null || (echo "'pip' (Python package management) is required!" \
		"Please make sure it is installed and available on PATH"; exit 1)
	@type terraform > /dev/null || (echo "'terraform' is required!" \
		"Please make sure it is installed and available on PATH"; exit 1)
	@type jq > /dev/null || (echo "'jq' is required!" \
		"Please make sure it is installed and available on PATH"; exit 1)
	@echo "Requirements are met!"

# install walt
install-walt:
	@echo "Installing walt..."
	@pip install git+https://github.com/scorphus/walt
	@type walt > /dev/null || (echo "'walt' script could not be found!" \
		"Please make sure it is installed and available on PATH"; exit 1)
.PHONY: install-walt

# use terraform to create/update infrastructure
terraform-apply:
	@echo "Creating/updating infrastructure with terraform..."
	@terraform init
	@terraform apply
.PHONY: terraform-apply

# create SSL certificate files
generate-certs:
	@echo "Generating SSL certificates..."
	@terraform state pull | jq -r '.resources[] | select(.name | contains("project")) | .instances[0].attributes.ca_cert' > ca_cert.pem
	@terraform state pull | jq -r '.resources[] | select(.name | contains("kafka_user")) | .instances[0].attributes.access_cert' > access_cert.pem
	@terraform state pull | jq -r '.resources[] | select(.name | contains("kafka_user")) | .instances[0].attributes.access_key' > access_key.pem
.PHONY: generate-certs

# generate config.toml file for walt
generate-config:
	@echo "Generating walt config file..."
	@env \
		WALT_KAFKA_URI=$$(terraform state pull | jq -r '.resources[] | select(.name | contains("kafka_service")) | .instances[0].attributes.service_uri') \
		WALT_KAFKA_CAFILE=ca_cert.pem \
		WALT_KAFKA_CERTFILE=access_cert.pem \
		WALT_KAFKA_KEYFILE=access_key.pem \
		WALT_KAFKA_TOPIC=$$(terraform state pull | jq -r '.resources[] | select(.name | contains("kafka_topic")) | .instances[0].attributes.topic_name') \
		WALT_POSTGRES_HOST=$$(terraform state pull | jq -r '.resources[] | select(.name | contains("postgres_service")) | .instances[0].attributes.service_host') \
		WALT_POSTGRES_PORT=$$(terraform state pull | jq -r '.resources[] | select(.name | contains("postgres_service")) | .instances[0].attributes.service_port') \
		WALT_POSTGRES_USER=$$(terraform state pull | jq -r '.resources[] | select(.name | contains("postgres_user")) | .instances[0].attributes.username') \
		WALT_POSTGRES_PASSWORD=$$(terraform state pull | jq -r '.resources[] | select(.name | contains("postgres_user")) | .instances[0].attributes.password') \
		WALT_POSTGRES_DBNAME=$$(terraform state pull | jq -r '.resources[] | select(.name | contains("postgres_database")) | .instances[0].attributes.database_name') \
		walt generate_config_sample_from_env > config.toml
.PHONY: generate-config

# create database tables
create-tables:
	@echo "Creating tables..."
	@walt -c config.toml create_tables
.PHONY: create-tables
