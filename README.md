# BlockchainTBA
Blockchain Testbed Automation for setting up the Cluster of Nodes for SmartchainDB
## Prerequisites


Before installing all necessary frameworks, ensure your **LOCAL**  system meets the following requirements:

- **Operating System**: Linux (Windows users can install via WSL2).
- **Python Version**: Python 3.8 or newer is required.
- **Pip**: Ensure `pip` (Python package installer) is installed.
- **Root Privileges**: Use `sudo` or have administrative privileges for system updates and package installations.

To verify the prerequisites, run the following commands:
```bash
python3 --version
pip --version
```

### Installing Terraform v1.9.0 on Linux amd64 (Local)



To install Terraform v1.9.0 on a Linux (amd64) system, follow these steps:

1. Download the Terraform v1.9.0 package:
    ```sh
    wget https://releases.hashicorp.com/terraform/1.9.0/terraform_1.9.0_linux_amd64.zip
    ```

2. Unzip the downloaded package:
    ```sh
    unzip terraform_1.9.0_linux_amd64.zip
    ```

3. Move the Terraform binary to a directory included in your system's `PATH`:
    ```sh
    sudo mv terraform /usr/local/bin/
    ```

4. Verify the installation:
    ```sh
    terraform -v
    ```

### Installing Ansible Core 2.12.10 on Linux (Local)
To install Ansible Core 2.12.10 on a Linux system, follow these steps:

1. Update your package list:
    ```sh
    sudo apt-get update
    ```
2. Add the Ansible PPA (Personal Package Archive):
    ```sh
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    ```    
3. Install Ansible Core 2.12.10:

    ``` sh
    sudo apt-get install -y ansible=2.12.10-1ppa~focal
    ```
4. Verify the installation:

    ``` sh
    ansible --version
    ```
The output should look like this : ansible [core 2.12.10]

You should see the output indicating that Terraform v1.9.0 is installed.

### Installing doctl on Linux amd64  (Local)

To install doctl on a Linux (amd64) system, follow these steps:

1. Download the latest release of doctl:
    ```sh
    cd ~
    wget https://github.com/digitalocean/doctl/releases/download/v1.119.0/doctl-1.119.0-linux-amd64.tar.gz
    ```

2. Extract the downloaded package:
    ```sh
    tar xf ~/doctl-1.119.0-linux-amd64.tar.gz
    ```

3. Move the doctl binary to a directory included in your system's `PATH`:
    ```sh
    sudo mv ~/doctl /usr/local/bin
    ```

4. Verify the installation:
    ```bash
    doctl version
    ```

You should see the output **doctl version 1.119.0-release** indicating that doctl is installed.

### Adding an SSH Key to DigitalOcean using doctl

To add an SSH key to your DigitalOcean account using doctl, follow these steps:



1. Retrieve you digital ocean API token from your account 

    1. Login to https://cloud.digitalocean.com/login
    2. Navigate to API -> Tokens
        - You can either create new one or regenerate existing. 
        ![alt text](/figures/image.png)
        - `copy` the token cause it won't be showed again and you would have to **regenrate** new one
        ![alt text](/figures/image-1.png)

2. Navigate to the root directory of the project:
   ```bash
   cd /path/to/BlockchainTBA
    ```
3. Create `.env` file

    ``` bash
    touch .env
    ```
4. `paste` the copied token into `.env`

    ``` bash
    echo "DO_API_TOKEN=your_digitalocean_api_token" >> .env
    ```
5. Use the source command to load the `.env` file:

    ``` bash
    source .env
    ```
6. Verify the token is loaded

    ``` bash
    echo $DO_API_TOKEN
    ```
7. Authenticate doctl with your DigitalOcean account:
    ```bash
    doctl auth init --access-token $DO_API_TOKEN
    ```
    You should see the following output:

    ``` bash
    Using token for context default

    Validating token... ✔
    ```

8. Add your SSH key to DigitalOcean. Replace `<key-name>` with a name for your SSH key. The `--public-key-file` flag should point to the path of your public SSH key file.

    ```sh
    doctl compute ssh-key import <key-name> --public-key-file ~/.ssh/id_rsa.pub
    ```
    > **Note:** If you don't have an SSH key pair, you can create one by following these steps:: 
    -  Creating a New Key Pair (if needed)
        1. Open a terminal and run the following command:
            ```sh
            ssh-keygen
            ```

        2. You will be prompted to save and name the key:
            ```sh
            Generating public/private rsa key pair.
            Enter file in which to save the key (/Users/USER/.ssh/id_rsa):
            ```

        3. Next, you will be asked to create and confirm a passphrase for the key (highly recommended):
            ```sh
            Enter passphrase (press Enter for no passphrase): 
            Enter same pass
3. Verify the SSH key has been added:
    ```sh
    doctl compute ssh-key list
    ```
    You should see your SSH key listed in the output.


### Source code customizations

1. In `resource_group.tf` copy your digital ocean token

    ```bash
    provider "digitalocean" {
    token = "your_digitalocean_token"
    }
    ```
2. In `resource_group.tf` copy your SSH key name

    ```bash 
    data "digitalocean_ssh_key" "smartchaindb" {
    name = "your_ssh_key_name"
    }
    ```
3. In `playbook.yml` make sure to set path to your SSH private key

    ```yaml 
    ansible_ssh_private_key_file: /path/to/your/private_key
    ```

    Example

    ```yaml 
    ansible_ssh_private_key_file: /home/korchien/.ssh/id_rsa
    ```
4. In `resource_group.tf` make sure to replicate the path to your private key as you put above

    ```bash 
      provisioner "local-exec" {
    command = <<EOF
      echo '${self.ipv4_address} ansible_user=root ansible_ssh_private_key_file=ath/to/your/private_key' >> ./.configs/hosts;
        EOF
    }
    ```



## Running the scripts

### 1. Node creation

This script automates the initialization and application of your Terraform infrastructure. Run:

``` bash
./scripts/init-infras.sh 
```

 >  Ensure the script is executable. Check the permissions using:
 
    ls -l init-infras.sh

> If you see something like -rw-r--r--, it means the script is not executable. Make it executable by running:

``` bash 
chmod +x init-infras.sh
```
> After that again re-run the script

### 2. Node Initialization 

This script installs the `jq` utility on all nodes, initializes tendermint and gathers all tendermint host information and saves it inot the file `BlockchainTBA/.configs/tendermint_info.json`

```bash 
./scripts/init-nodes.sh 
```

### 3. Copy `genesis.json` and `config.toml` from a node

This script extracts the first IP address from a specified hosts file and uses `scp` to copy specific configuration files (`genesis.json` and `config.toml`) from a remote Tendermint node at that IP address to local  `BlockchainTBA/.configs/` path. It also checks if the file copy operation was successful and outputs the result.

```bash 
./scripts/copyfiles.sh
```


>**NOTE:** If you are unable to access .config folder and you are getting the following error:

```python 
Copying /root/.tendermint/config/config.toml from 161.35.104.174 to ./.configs/config.toml
root@161.35.104.174: Permission denied (publickey).
```
- Add `your/path/to/private_key` in `/scripts/copyfiles.sh` to the following line:

```bash 
sudo scp -i your/path/to/private_key root@"$IP_ADDR_OF_FIRST_NODE":"$src_file" "$dest_file"
```


- Check permissions

```bash 
ls -ld ./.configs
```

Example output: `drwx------ 2 user user 4096 Nov 24 15:00 .configs`

- if it is not your username in place of `user` change the permission by running:

```bash 
sudo chown -R $(whoami):$(whoami) ./.configs
```

- Verify the changes

```bash 
ls -ld ./.configs
```

### 4. Update `genesis.json` and `config.toml` and distribute to the nodes

```bash 
./scripts/update-genesis.sh
```

```bash 
./scripts/update-config.sh
```

### 5. Update the Tendermint Host IP address in `docker-compose.yml`
By udpating IP address for Tendermint Host in docker-compose.yml file, we are enabling SmartchainDB application connect to Tendermint

```bash 
./scripts/update-tendermint-host.sh
```

### 6. Start the application
Starts SmartchainDB, MongoDB and Tendermint in all nodes

```bash 
./scripts/start-services.sh
```

### 7. Stop the application
Stops SmartchainDB, MongoDB and Tendermint in all nodes

```bash 
./scripts/stop-services.sh
```

### To delete all nodes run

```bash 
terraform destroy -lock=false
```