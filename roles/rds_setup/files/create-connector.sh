#!/bin/bash

CONFIG_FILE="$1"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: Config file not found: $CONFIG_FILE"
  exit 1
fi

curl -X POST http://localhost:8083/connectors \
     -H "Content-Type: application/json" \
     -d "@$CONFIG_FILE"