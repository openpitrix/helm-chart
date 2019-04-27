#!/bin/bash

set -ev

CONFIG_FILE="./templates/config.json"

getValueFromJsonFile() {
  key=$1
  while read line; do
    in=$(echo ${line}|grep ${key})
    if [ "${in}" != "" ];then
      echo ${line} | cut -f 2 -d ":" | cut -f 1 -d "," | cut -f 2 -d "\""
    fi
  done < ${CONFIG_FILE}
}

# generate openpitrix config.json
CLIENT_ID=$(getValueFromJsonFile "iam_client_id")
CLIENT_SECRET_KEY=$(getValueFromJsonFile "iam_client_secret")
IP=$(minikube ip)
API_GATEWAY_NODEPORT=$(kubectl get svc openpitrix-api-gateway -o jsonpath='{.spec.ports[0].nodePort}')

mkdir -p ~/.openpitrix/
sed -e "s,{{CLIENT_ID}},${CLIENT_ID},g" \
    -e "s,{{CLIENT_SECRET_KEY}},${CLIENT_SECRET_KEY},g" \
    -e "s,{{ENDPOINT}},${IP},g" \
    -e "s,{{API_GATEWAY_NODEPORT}},${API_GATEWAY_NODEPORT},g" ./templates/openpitrix-config.json.tmpl > ~/.openpitrix/config.json

# download openpitrix code
if [ -d "${GOPATH}/src/openpitrix.io/openpitrix" ];then
  rm -rf ${GOPATH}/src/openpitrix.io/openpitrix
else
  mkdir -p ${GOPATH}/src/openpitrix.io
fi
cd ${GOPATH}/src/openpitrix.io
git clone -b tmp https://github.com/yudong2015/openpitrix.git
cd openpitrix

# ignored files that don't need to be tested here
rm -rf ./test/devkit

make e2e-test
make e2e-k8s-test
