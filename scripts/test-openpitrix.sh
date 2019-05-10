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


######### generate openpitrix config.json
CLIENT_ID=$(getValueFromJsonFile "iam_client_id")
CLIENT_SECRET_KEY=$(getValueFromJsonFile "iam_client_secret")
IP=$(minikube ip)
API_GATEWAY_NODEPORT=$(kubectl get svc openpitrix-api-gateway -o jsonpath='{.spec.ports[0].nodePort}')

mkdir -p ~/.openpitrix/
sed -e "s,{{CLIENT_ID}},${CLIENT_ID},g" \
    -e "s,{{CLIENT_SECRET_KEY}},${CLIENT_SECRET_KEY},g" \
    -e "s,{{ENDPOINT}},${IP},g" \
    -e "s,{{API_GATEWAY_NODEPORT}},${API_GATEWAY_NODEPORT},g" ./templates/openpitrix-config.json.tmpl > ~/.openpitrix/config.json


######### download openpitrix code
OPENPITRIX_HOME=${GOPATH}/src/openpitrix.io
mkdir -p ${OPENPITRIX_HOME}
git clone https://github.com/openpitrix/openpitrix.git ${OPENPITRIX_HOME}/openpitrix

# get branch or tag
if [ ${TRAVIS_TAG} ];then
  #get openpitrix version
  VERSIONS=`bash ./scripts/chart-openpitrix-version.sh`
  if [ $? -eq 0 ]; then
    export ${VERSIONS}
  else
    # echo error message
    echo ${VERSIONS}
    exit 1
  fi
  BRANCH=${appVersion}
else
  BRANCH=master
fi
cd ${OPENPITRIX_HOME}/openpitrix
git checkout ${BRANCH} #checkout tag to openpitrix version

####### run test
# ignored files that don't need to be tested here
rm -rf ./test/devkit
make e2e-test
make e2e-k8s-test
