#!/bin/bash
for server in lb01 db01 app01 app02; do
  IP=$(grep "public network" $server.Details | awk -F "|" '{print $3}' | egrep -o " [0-9]\..*$| [0-9][0-9]\..*$| [0-9][0-9][0-9]\..*$" | sed 's/,.*$//g' | sed 's/ //g')
  sed -i "s/<$server-ip>/$IP/g" playbooks/pushHostsFile.yaml
done

MASTERIP=$(ip a s eth0 | grep "inet " | awk -F "/" '{print $1}' | awk '{print $2}')
sed -i "s/<ansible-master-ip>/$MASTERIP/g" playbooks/pushHostsFile.yaml

ansible-playbook playbooks/pushHostsFile.yaml
