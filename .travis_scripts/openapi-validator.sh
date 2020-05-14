#!/usr/bin/env bash
set -e
for entry in ./public/doc/openapi-3-v*.json
do
  ./openapi-generator-cli validate -i "$entry"
done

