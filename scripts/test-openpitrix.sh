#!/usr/bin/env bash

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

CLIENT_ID=$(getValueFromJsonFile "iam_client_id")
CLIENT_SECRET=$(getValueFromJsonFile "iam_client_secret")
NODEPORT=$(sudo kubectl get svc openpitrix-api-gateway -o jsonpath='{.spec.ports[0].nodePort}')

mkdir -p ~/.openpitrix/
sed -e "s,{{CLIENT_ID}},${CLIENT_ID},g" \
    -e "s,{{CLIENT_SECRET}},${CLIENT_SECRET},g" \
    -e "s,{{NODEPORT}},${NODEPORT},g" ./templates/openpitrix-config.json.tmpl > ~/.openpitrix/config.json

mkdir -p ${GOPATH}/src/openpitrix.io
cd ${GOPATH}/src/openpitrix.io
git clone https://github.com/openpitrix/openpitrix.git
cd openpitrix
make test
