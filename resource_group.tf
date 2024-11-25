terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0" // Specify a suitable version
    }
  }
}

provider "digitalocean" {
  token = "your_digitalocean_token"
}

resource "null_resource" "reset_inventory" {
  # Runs before any droplet is created
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ./.configs/node_ids
      echo "[smartchaindb]" > ./.configs/hosts
      > ./.configs/tendermint_info.json
      > ./.configs/node_ids/host_names.txt
      rm -f ./.configs/genesis.json
      rm -f ./.configs/config.toml
    EOF
  }
}

data "digitalocean_ssh_key" "smartchaindb" {
  name = "your_ssh_key_name"
}

resource "digitalocean_droplet" "smartchaindb" {
  count    = 4
  name     = "smartchaindb-${count.index}"
  size     = "s-4vcpu-8gb-240gb-intel"
  image    = "ubuntu-20-04-x64"
  region   = "nyc1"
  ssh_keys = [data.digitalocean_ssh_key.smartchaindb.id]
  user_data   = "${file("./install_dependencies_server.sh")}"

  provisioner "local-exec" {
    command = <<EOF
      echo '${self.ipv4_address} ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa' >> ./.configs/hosts;
    EOF
  }
}

output "droplet_ips" {
  value = digitalocean_droplet.smartchaindb.*.ipv4_address
}
