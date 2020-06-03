#!/usr/bin/env bash
set -eu
set -o pipefail

if ! ./openapi-generator-cli version
then
  echo "openapi-generator-cli version failed, likely caused by a mvn build failure. Retry once."
  ./openapi-generator-cli version
fi

for entry in ./public/doc/openapi-3-v*.json
do
  ./openapi-generator-cli validate -i "$entry"
done

