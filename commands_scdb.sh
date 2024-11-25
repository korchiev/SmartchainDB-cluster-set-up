sudo terraform init

sudo terraform apply # if needed -lock=false

sudo nano ./.configs/hosts

sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "install_jq"

sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "tendermint_init"

sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "get_pub_key,get_node_id,gather_ip,collect_data,print_info,dump_info"

sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "copy_genesis"

sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "copy_config"

sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "start_db"

sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "start_tendermint"

sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "stop_db"

sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "tendermint_stop"

sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "reset_tendermint"