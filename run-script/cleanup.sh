#!/bin/bash
sudo find * -type d -name data -exec rm -rf {} +
find servers/* -name docker-compose.yaml -exec sh -c 'docker compose -f {} down' \;
sudo find keycert/{clients,servers}/* -type d -exec rm -rf {} +
sudo find * -type d -name cert -exec rm -rf {} +
