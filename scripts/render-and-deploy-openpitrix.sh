#!/bin/bash

if [ -z "${TRAVIS_TAG}" ]; then
  CHART_VERSION="latest"
  TRAVIS_TAG="master"
else
  CHART_VERSION=${TRAVIS_TAG}
fi

echo ${CHART_VERSION}
# get appVersion(openpitrix version) by CHART_VERSION(helm chart version)
VERSIONS=`bash ./scripts/chart-openpitrix-version.sh ${CHART_VERSION}`
if [ $? -eq 0 ]; then
  export ${VERSIONS}
else
  # echo error message
  echo ${VERSIONS}
  exit 1
fi

#get versions and images from version.sh
curl -O https://raw.githubusercontent.com/openpitrix/openpitrix/${TRAVIS_TAG}/deploy/version.sh
OP_VERSIONS_IMAGES=`bash version.sh openpitrix-${appVersion}`
if [ $? -eq 0 ]; then
  export ${OP_VERSIONS_IMAGES}
else
  # echo error message
  echo ${OP_VERSIONS_IMAGES}
  exit 1
fi

# At first, you should install handlerbars impl with by pybars3, git-repo: git@github.com:wbond/pybars3.git
python ./scripts/handlebars-renderer.py -i ./templates/values.yaml.handlebars -v ./templates/config.json -o ./openpitrix/values.yaml -e
python ./scripts/handlebars-renderer.py -i ./templates/Chart.yaml.handlebars -v ./templates/config.json -o ./openpitrix/Chart.yaml -e

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
