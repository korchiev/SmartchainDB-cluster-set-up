sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "stop_db"

sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "tendermint_stop"

sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "reset_tendermint"