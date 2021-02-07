# walt.tf

walt.tf — Infrastructure as code for [walt]

With the contents of this repository, you can create the set of services that
walt depends on. The Terraform HCL files assume you'll use the [Aiven] services.

## Requirements

In order to be able to create the infrastructure and configure walt, you'll need
the following:

- [Make] - To execute the ready-to-use commands
- [Python >= 3.8][python] - To install and run walt
- [Terraform] - To provision the infrastructure
- [jq] - To generate walt's config and certificate files

## Usage

Follow these instructions once you cloned the repository.

### Terraform variables

Before you proceed, you must open `variables.tf` in you editor and define the
variables according to your Aiven account.

### Steps

> Note: You'll be prompted for confirmation by `terraform apply`

In case you want all steps below to be executed at once, run `make all`.
Otherwise, here are the steps:

1. After cloning the repo, ensure the requirements are met:

       $ make assert-requirements

2. Install walt:

       $ make install-walt

3. Create infrastructure with terraform:

       $ make terraform-apply

4. Generate certificate files:

       $ make generate-certs

5. Generate walt's config file:

       $ make generate-config

6. Check the contents of walt's config file:

       $ cat config.toml

7. Create database tables on Postgre:

       $ make create-tables

## Running walt

After reviewing `config.toml`, you might want to change it as you see fit. To
better understand what each config entry represents, check walt's
[README][walt].

From here, you're hopefully ready to consume/produce results:

    $ walt -c config.toml consume
    $ walt -c config.toml produce

Yo may want to run `produce` and `consume` in different shell
sessions/tabs/windows.

## License

Code in this repository is distributed under the terms of the BSD 3-Clause
License (BSD-3-Clause).

See [LICENSE] for details.

[walt]: https://github.com/scorphus/walt
[Aiven]: https://aiven.io/
[terraform]: https://learn.hashicorp.com/tutorials/terraform/install-cli
[python]: https://www.python.org/downloads/
[jq]: https://stedolan.github.io/jq/
[Make]: https://www.gnu.org/software/make/
[license]: LICENSE
