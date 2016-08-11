#!/bin/bash

#Define variables for building the server
IMAGE="4b3e2127-4623-43df-a938-e60268c236c2"
FLAVOR="general1-1"
KEYNAME="WorkPC"
SUPERNOVA_ENV="pg"
SERVERS="lb01 app01 app02 bd01"
#SERVERS="ansible-test-LB"


for SERVER in ${SERVERS}; do
  /usr/local/bin/supernova "${SUPERNOVA_ENV}" boot --image "${IMAGE}" --flavor "${FLAVOR}" --key-name "${KEYNAME}" ${SERVER} &> /root/ansible-learning/${SERVER}.buildDetails
done;

sleep 5

echo -e "\n### Automated build entries: ###"  >> /etc/hosts
for SERVER in ${SERVERS}; do
  # get the servers details and output to a file
  UUID=$(grep " id " /root/ansible-learning/${SERVER}.buildDetails | awk '{print $4}')
  /usr/local/bin/supernova "${SUPERNOVA_ENV}" show ${UUID} &> /root/ansible-learning/${SERVER}.Details
  
  # from those details add a hosts entry
  IPS=$(grep " public network " /root/ansible-learning/${SERVER}.Details | awk -F "|" '{print $3}' | sed 's/,//g')
  # For both IPv6 and IPv4
  for IP in ${IPS}; do
    if [[ $(grep -c "${IP}" /etc/hosts) == 0 ]]; then
      echo -e "${IP}\t$SERVER" >> /etc/hosts
    fi
  done
  rm -rvf /root/ansible-learning/${SERVER}.buildDetails
done

echo -e "\n### END Automated build entries ###"  >> /etc/hosts

