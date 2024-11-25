#!/bin/bash

# Paths to genesis and tendermint_info files
GENESIS_FILE="./.configs/genesis.json"
TENDERMINT_INFO_FILE="./.configs/tendermint_info.json"
TEMP_GENESIS_FILE="./.configs/tmp_genesis.json"

# Create a new empty validators array
new_validators="[]"

echo "Updating validators in genesis.json..."

# Read tendermint_info.json without piping into the while loop (to avoid subshell issue)
while read -r node; do
  pub_key=$(echo "$node" | jq -r '.pub_key')
  node_id=$(echo "$node" | jq -r '.node_id')
  ip=$(echo "$node" | jq -r '.ip')

  echo "Processing node with IP: $ip, Node ID: $node_id, Public Key: $pub_key"

  # Create a new validator entry based on the node information
  new_validator=$(jq -n --arg pub_key "$pub_key" --arg node_id "$node_id" --arg ip "$ip" '
    {
      "pub_key": {
        "type": "tendermint/PubKeyEd25519",
        "value": $pub_key
      },
      "power": "10",
      "name": "",
    }')

  # Add the new validator to the new_validators array
  new_validators=$(echo "$new_validators" | jq --argjson new_validator "$new_validator" '. + [$new_validator]')

  # echo "Validator added: $new_validator"
done < <(jq -c '.[][]' "$TENDERMINT_INFO_FILE")  # Process substitution to feed data into the while loop

# Debug output of new_validators array
# echo "Final validators array: $new_validators"

# Update the validators array in the genesis.json file
jq --argjson new_validators "$new_validators" '.validators = $new_validators' "$GENESIS_FILE" > $TEMP_GENESIS_FILE && mv $TEMP_GENESIS_FILE "$GENESIS_FILE"

echo "Updated validators in genesis.json."

echo "Running ansible playbook to copy the updated genesis.json to the nodes..."
sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "copy_genesis"

echo "Genesis update complete."
