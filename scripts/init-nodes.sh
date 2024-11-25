sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "install_jq"

sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "tendermint_init"

sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "get_pub_key,get_node_id,gather_ip,collect_data,print_info,dump_info"