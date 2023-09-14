#!/bin/bash

source run-script/.env

for EACH_CFG_SVR in servers/config/*/;
do
    CFG_SVR=${EACH_CFG_SVR/'servers/config/'/}
    CFG_SVR=(${CFG_SVR%/})
    CFG_PORT=`cat ${EACH_CFG_SVR}/.env | grep MONGO_PORT | awk -F'=' '{printf $2}'`
    CLUSTER_ID=`cat ${EACH_CFG_SVR}/.env | grep REPLSET_NAME | awk -F'=' '{printf $2}'`
    
    for EACH in ${CFG_SVR[@]};
    do
        if [ -f "${EACH_CFG_SVR}/cluster-compose.yaml" ];
        then
            RPS_PRIME=${CFG_SVR}
            RPS_PRIME_PORT=${CFG_PORT}
            CFG_DB_USER=`cat ${EACH_CFG_SVR}/.env | grep INITDB_ROOT_USERNAME | awk -F'=' '{printf $2}'`
            CFG_DB_PASSWORD=`cat ${EACH_CFG_SVR}/.env | grep INITDB_ROOT_PASSWORD | awk -F'=' '{printf $2}'`
        else
            docker compose -f ${EACH_CFG_SVR}/docker-compose.yaml up -d
            CFG_SERVERS=("${CFG_SERVERS[@]}" "${CFG_SVR}")
            CFG_SERVERS_PORT=("${CFG_SERVERS_PORT[@]}" "${CFG_PORT}")
        fi
    done
done

bash servers/config/${RPS_PRIME}/initscript

sleep 5

mongosh \
--quiet \
--authenticationDatabase admin \
--tls \
--tlsCAFile="${DB_CAFILE}" \
--tlsCertificateKeyFile="${DB_PEMKEYFILE}" \
--username=${CFG_DB_USER} \
--password=${CFG_DB_PASSWORD} \
${RPS_PRIME}.${DOMAIN_NAME}:${RPS_PRIME_PORT} \
--eval "rs.initiate({
  _id: \"${CLUSTER_ID}\",
  configsvr: true,
  members: [
    { _id: 0, host: \"${RPS_PRIME}.${DOMAIN_NAME}:${RPS_PRIME_PORT}\", priority: 10 },
    { _id: 1, host: \"${CFG_SERVERS[0]}.${DOMAIN_NAME}:${CFG_SERVERS_PORT[0]}\" },
    { _id: 2, host: \"${CFG_SERVERS[1]}.${DOMAIN_NAME}:${CFG_SERVERS_PORT[1]}\" },
  ],
});"

while read -r LINE;
do
  if [[ ${LINE} == CFG_DB_USER=* ]];
  then
    DATA=`echo -e "CFG_DB_USER=${CFG_DB_USER}\n${DATA}"` 
  elif [[ ${LINE} == CFG_DB_PASSWORD=* ]];
  then
    DATA=`echo -e "CFG_DB_PASSWORD=${CFG_DB_PASSWORD}\n${DATA}"` 
  else
    DATA=`echo -e "${LINE}\n${DATA}"`
  fi
done <<< `cat run-script/.env`

echo -e "${DATA}" > run-script/.env