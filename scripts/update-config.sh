#!/bin/bash

# Paths to config.toml and tendermint_info.json
CONFIG_FILE="./.configs/config.toml"
TENDERMINT_INFO_FILE="./.configs/tendermint_info.json"

# Function to update a field in the config.toml
update_toml_field() {
  local field_name="$1"
  local field_value="$2"
  local config_file="$3"

  # Check if the field exists in the file, and update it
  # Use a more specific pattern to match only the exact field name
  if grep -q "^$field_name = " "$config_file"; then
    sed -i.bak "s|^$field_name = .*|$field_name = $field_value|" "$config_file"
  else
    echo "$field_name = $field_value" >> "$config_file"
  fi
}

# Build the persistent_peers value using tendermint_info.json
persistent_peers=""
while read -r node; do
  node_id=$(echo "$node" | jq -r '.node_id')
  ip=$(echo "$node" | jq -r '.ip')

  if [ -n "$persistent_peers" ]; then
    persistent_peers+=","
  fi
  persistent_peers+="${node_id}@${ip}:26656"
done < <(jq -c '.[][]' "$TENDERMINT_INFO_FILE")

# Update fields in config.toml
update_toml_field "create_empty_blocks" "false" "$CONFIG_FILE"
update_toml_field "log_level" "\"main:info,state:info,*:error\"" "$CONFIG_FILE"
update_toml_field "persistent_peers" "\"$persistent_peers\"" "$CONFIG_FILE"
update_toml_field "send_rate" "102400000" "$CONFIG_FILE"
update_toml_field "recv_rate" "102400000" "$CONFIG_FILE"
update_toml_field "recheck" "false" "$CONFIG_FILE"

echo "config.toml has been updated successfully."

echo "Running ansible playbook to copy the updated config.toml to the nodes..."
sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "copy_config"

echo "Configuration update complete."