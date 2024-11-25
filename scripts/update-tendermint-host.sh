#!/bin/bash

# Path to the JSON file containing node information
TENDERMINT_INFO_FILE="./.configs/tendermint_info.json"

# Ensure the JSON file exists
if [[ ! -f "$TENDERMINT_INFO_FILE" ]]; then
  echo "ERROR: JSON file $TENDERMINT_INFO_FILE not found!"
  exit 1
fi

# Initialize node count
node_count=0

# Loop through the node groups in the JSON file
for node_group in $(jq -c '.[]' "$TENDERMINT_INFO_FILE"); do
  echo "Node group: $node_group"

  # Loop through each node in the group
  for node in $(echo "$node_group" | jq -r '.[] | @base64'); do
    node_count=$((node_count + 1))

    # Decode the node JSON object
    _jq() {
      echo "$node" | base64 --decode | jq -r "$1"
    }

    # Extract the IP address for the node
    IP=$(_jq '.ip')

    echo "Updating BIGCHAINDB_TENDERMINT_HOST on node with IP: $IP"

    # Define the remote path and the file to be updated
    REMOTE_PATH="~/smartchaindb/docker-compose.yml"

    # Use SSH to update the BIGCHAINDB_TENDERMINT_HOST in docker-compose.yml
    ssh root@$IP "
      if [ -f $REMOTE_PATH ]; then
        sed -i 's/BIGCHAINDB_TENDERMINT_HOST:.*/BIGCHAINDB_TENDERMINT_HOST: $IP/' $REMOTE_PATH &&
        echo '-> Successfully updated BIGCHAINDB_TENDERMINT_HOST to $IP in $REMOTE_PATH'
      else
        echo '-> ERROR: File $REMOTE_PATH not found on $IP'
      fi
    "

    # Check the exit status of the SSH command
    if [[ $? -ne 0 ]]; then
      echo "Failed to update BIGCHAINDB_TENDERMINT_HOST on $IP"
    fi
  done
done

# Print the total node count
echo "Updated BIGCHAINDB_TENDERMINT_HOST on $node_count nodes."
