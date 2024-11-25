#!/bin/bash

# This script is used to install the necessary infrastructure tools for the project
TFVERSION=$(terraform --version)

echo "Using $TFVERSION"

sudo rm -rf .configs
sudo rm -rf .terraform
sudo rm -rf terraform.tfstate
sudo rm -rf .terraform.lock.hcl
sudo rm -rf .terraform

sudo terraform init
sudo terraform apply -auto-approve
