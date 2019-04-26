#!/bin/bash

sudo helm install -n openpitrix openpitrix

until sudo helm list --deployed openpitrix | grep -w openpitrix; do sleep 3; done
echo "Check status of openpitrix deployments..."
TIMES=0
while [ $(sudo kubectl get deployments --no-headers | awk '{print $4}'|grep 0|wc -l) -gt 0 ]&&[ ${TIMES} -lt 100 ];do
  TIMES=`expr ${TIMES} + 1`
  echo "Retry ${TIMES} times..."
  sleep 6
done
sudo kubectl get deployments
