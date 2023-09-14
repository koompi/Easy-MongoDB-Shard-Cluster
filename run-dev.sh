#!/bin/bash

## please run this script in this directory ##

bash run-script/cleanup.sh
bash run-script/setup-cert.sh
bash run-script/setup-cfg.sh
bash run-script/setup-shard.sh
bash run-script/setup-router.sh
bash migration-script/export-db.sh
bash migration-script/import-db.sh