#!/usr/bin/env bash

set -ev

mkdir -p ${GOPATH}/src/openpitrix.io
cd ${GOPATH}/src/openpitrix.io
git clone https://github.com/openpitrix/openpitrix.git
cd openpitrix

mkdir -p ~/.openpitrix/
NODEPORT=$(sudo kubectl get svc openpitrix-api-gateway -o jsonpath='{.spec.ports[0].nodePort}')
sed "s,NODEPORT,${NODEPORT},g" /home/travis/build/openpitrix/helm-chart/templates/config.json.tmpl > ~/.openpitrix/config.json

#sudo go test -v -a -tags="integration" ./test/...
#sudo go test -v -a -timeout 0 -tags="k8s" ./test/...
