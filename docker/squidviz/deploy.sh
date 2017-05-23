#!/bin/bash
wget https://raw.githubusercontent.com/ggpwnkthx/coach/master/docker/squidviz/Dockerfile -O Dockerfile
sudo docker build -t "coach/squidviz" .
if [ ! -z "$(sudo docker ps | grep squidviz)" ]
then
  sudo docker kill squidviz
fi
if [ ! -z "$(sudo docker ps -a | grep squidviz)" ]
then
  sudo docker rm squidviz
fi
sudo chmod +r /etc/ceph
sudo chmod +r /etc/ceph/*
sudo docker run -d --name squidviz \
  -v /etc/ceph:/etc/ceph \
  -p 80:80 \
  coach/squidviz