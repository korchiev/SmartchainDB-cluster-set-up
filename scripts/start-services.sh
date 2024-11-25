sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "start_db"

sudo ansible-playbook -i ./.configs/hosts playbook.yml --tags "start_tendermint"