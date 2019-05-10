#!/bin/bash

chart_latest="
  version=latest
  appVersion=latest
"

chart_v0_4_0="
  version=v0.4.0
  appVersion=v0.4.1
"

VERSION=$1

CHART_VERSION=${VERSION//./_}
VAR="chart_${CHART_VERSION}"
VERSIONS=`eval echo '$'"${VAR}"`

# check if the given version exist
if [ "x${VERSIONS}" == "x" ]; then
  echo "The version ${VERSION} of helm-chart not exist!"
  exit 1
fi

#echo versions
for V in ${VERSIONS} ; do
  echo ${V}
done
