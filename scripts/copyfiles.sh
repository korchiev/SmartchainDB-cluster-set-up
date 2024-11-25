#!/bin/bash

# Define the path to the hosts file
HOSTS_FILE="./.configs/hosts"

# Use grep to find the IP addresses and awk to extract the first one
IP_ADDR_OF_FIRST_NODE=$(grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' "$HOSTS_FILE" | head -n 1)

# Output the first IP address
echo "The first IP address is: $IP_ADDR_OF_FIRST_NODE"

# Define the files to copy and the destination
FILES_TO_COPY=(
  "/root/.tendermint/config/genesis.json:./.configs/genesis.json"
  "/root/.tendermint/config/config.toml:./.configs/config.toml"
)

# Loop through each file in the FILES_TO_COPY array
for file_pair in "${FILES_TO_COPY[@]}"; do
  # Split the source and destination based on the colon delimiter
  IFS=":" read -r src_file dest_file <<< "$file_pair"
  
  # Perform the file copy with scp
  echo "Copying $src_file from $IP_ADDR_OF_FIRST_NODE to $dest_file"
  sudo scp root@"$IP_ADDR_OF_FIRST_NODE":"$src_file" "$dest_file"
  echo "-> Copied $src_file to $dest_file"

  # Check if the scp was successful
  if [[ $? -ne 0 ]]; then
    echo "Failed to copy $src_file to $dest_file"
  fi
done

# modify the genesis.json file

# Run copy_genesis playbook

# Run copy_config playbook
