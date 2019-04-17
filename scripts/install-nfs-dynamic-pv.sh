#!/bin/bash

IP=$(sudo minikube ip)
echo "IP: ${IP}"
NFS_DIR="/var/nfs"

#install nfs server
sudo apt install nfs-kernel-server
sudo mkdir -p ${NFS_DIR}
sudo sh -c 'echo "/var/nfs *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports'
sudo exportfs -rv
sudo service nfs-kernel-server restart

#install nfs-client-provisioner
helm install stable/nfs-client-provisioner --set nfs.server=${IP} --set nfs.path=${NFS_DIR} --name nfs-client-provisioner
#set storageClass to default
kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
