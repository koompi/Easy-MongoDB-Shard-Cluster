#!/bin/bash

source run-script/.env

docker compose -f ${MONGOS_PATH}/docker-compose.yaml up -d

RPS_PRIME=${MONGOS_PATH%/}
RPS_PRIME=`echo "${MONGOS_PATH}" | awk -F'/' '{printf $NF}'`
RPS_PRIME_PORT=`cat "${MONGOS_PATH}"/.env | grep MONGO_PORT | awk -F'=' '{printf $NF}'`

sleep 5

for EACH_SHARD in ${SHARD_TOTAL[@]};
do
  mongosh \
  --quiet \
  --authenticationDatabase admin \
  --tls \
  --tlsCAFile="${DB_CAFILE}" \
  --tlsCertificateKeyFile="${DB_PEMKEYFILE}" \
  --username=${CFG_DB_USER} \
  --password=${CFG_DB_PASSWORD} \
  ${RPS_PRIME}.${DOMAIN_NAME}:${RPS_PRIME_PORT} \
  --eval "sh.addShard(\"${EACH_SHARD}\");"
done

while read -r LINE;
do
  if [[ ${LINE} == CFG_DB_USER=* ]] || [[ ${LINE} == CFG_DB_PASSWORD=* ]] || [[ ${LINE} == SHARD_TOTAL=* ]];
  then
    DATA=`echo -e "${LINE//=*/}=\"\"\n${DATA}"`
  else 
    DATA=`echo -e "${LINE}\n${DATA}"`
  fi
done <<< `cat run-script/.env`

echo -e "${DATA}" > run-script/.env