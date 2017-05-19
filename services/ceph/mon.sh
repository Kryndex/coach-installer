#!/bin/bash
read -p "Is this the first node? [y,N] " first
case $first in
  y|Y)
    sudo apt-get -y install net-tools ipcalc ceph-deploy
    if [ ! -d ~/ceph ]
    then
      mkdir ~/ceph
    fi
    cd ~/ceph
    sudo ceph-deploy $HOSTNAME
    ifconfig | awk -v RS="\n\n" '{ for (i=1; i<=NF; i++) if ($i == "inet" && $(i+1) ~ /^addr:/) address = substr($(i+1), 6); if (address != "127.0.0.1") printf "%s\t%s\n", $1, address }'
    read -p "Which adapter should be used for the ceph cluster? " nic
    addr=$(ifconfig $nic | grep Mask | awk '{print $2}' | awk '{split($0,a,":"); print a[2]}'
    mask=$(ifconfig $nic | grep Mask | awk '{print $4}' | awk '{split($0,a,":"); print a[2]}'
    net=$(ipcalc -n $addr $mask | grep Network | awk '{print $2}')
    echo "osd pool default size = 2" >> ceph.conf
    echo "public network = $net" >> ceph.conf
    ceph-deploy install $HOSTNAME
    ceph-deploy mon create-initial
    ceph-deploy admin $HOSTNAME
    chmod +r /etc/ceph
    chmod +r /etc/ceph/*
    chmod +r /var/lib/ceph
    chmod +r /var/lib/ceph/*
    chmod +r /var/lib/ceph/*/*
    ;;
  n|N)
    ifconfig | awk -v RS="\n\n" '{ for (i=1; i<=NF; i++) if ($i == "inet" && $(i+1) ~ /^addr:/) address = substr($(i+1), 6); if (address != "127.0.0.1") printf "%s\t%s\n", $1, address }'
    read -p "Which adapter should be used for the ceph cluster? " nic
    chaddr=$(ifconfig $nic | grep HWaddr | awk '{print $5}')
    mask=$(ifconfig $nic | grep Mask | awk '{print $4}' | awk '{split($0,a,":"); print a[2]}'
    net=$(ipcalc -n $addr $mask | grep Network | awk '{print $2}')
    read -p "What is the hostname or IP of an active node? " node
    ssh -t $node "ssh-keygen -R $HOSTNAME && ssh-copy-id $(whoami)@$HOSTNAME"
    ssh -t $node "cd ~/ceph && ceph-deploy mon create $HOSTNAME"
    ;;
esac
