#!/usr/bin/env bash

set -ev

if [ -z "${TRAVIS_TAG}" ]; then
    VERSION="latest"
else
    VERSION=${TRAVIS_TAG}
fi

sed "s,VERSION,${VERSION},g" ./templates/values.json.tmpl > ./templates/values.json

handlebars-renderer -i ./templates/values.yaml.handlebars -v ./templates/values.json -o ./openpitrix/values.yaml
handlebars-renderer -i ./templates/Chart.yaml.handlebars -v ./templates/values.json -o ./openpitrix/Chart.yaml

sudo helm install -n openpitrix openpitrix

until sudo helm list --deployed openpitrix | grep -w openpitrix; do sleep 1; done
