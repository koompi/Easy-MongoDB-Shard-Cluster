#!/bin/bash

source run-script/.env

for EACH_SHRD_SVR in servers/shards/*;
do
    SHRD_NAME=(${EACH_SHRD_SVR#'servers/shards/'})
    unset SHRD_SERVERS_PORT SHRD_SERVERS_PORT;
    
    for EACH_SHRD_CLUSTER in ${EACH_SHRD_SVR}/*/;
    do
        SHRD_CLUSTER_NAME=${EACH_SHRD_CLUSTER//"${EACH_SHRD_SVR}/"/}
        SHRD_CLUSTER_NAME=${SHRD_CLUSTER_NAME%/}
        SHRD_CLUSTER_PORT=`cat ${EACH_SHRD_CLUSTER}/.env | grep MONGO_PORT | awk -F'=' '{printf $2}'`
        CLUSTER_ID=`cat ${EACH_SHRD_CLUSTER}/.env | grep REPLSET_NAME | awk -F'=' '{printf $2}'`
        
        if [ -f "${EACH_SHRD_CLUSTER}/cluster-compose.yaml" ];
        then
            SHRD_PRIME=${SHRD_CLUSTER_NAME}
            SHRD_PRIME_PATH=${SHRD_NAME}/${SHRD_PRIME}
            SHRD_PRIME_PORT=${SHRD_CLUSTER_PORT}
            SHRD_DB_USER=`cat ${EACH_SHRD_CLUSTER}/.env | grep INITDB_ROOT_USERNAME | awk -F'=' '{printf $2}'`
            SHRD_DB_PASSWORD=`cat ${EACH_SHRD_CLUSTER}/.env | grep INITDB_ROOT_PASSWORD | awk -F'=' '{printf $2}'`
        else
            SHRD_SERVERS=("${SHRD_SERVERS[@]}" "${SHRD_CLUSTER_NAME}")
            SHRD_SERVERS_PORT=("${SHRD_SERVERS_PORT[@]}" "${SHRD_CLUSTER_PORT}")
            docker compose -f ${EACH_SHRD_CLUSTER}/docker-compose.yaml up -d
        fi
    done
    
    bash servers/shards/${SHRD_PRIME_PATH}/initscript

    sleep 5
    
    mongosh \
    --quiet \
    --authenticationDatabase admin \
    --tls \
    --tlsCAFile="${DB_CAFILE}" \
    --tlsCertificateKeyFile="${DB_PEMKEYFILE}" \
    --username=${SHRD_DB_USER} \
    --password=${SHRD_DB_PASSWORD} \
    ${SHRD_PRIME}.${DOMAIN_NAME}:${SHRD_PRIME_PORT} \
    --eval "rs.initiate({
  _id: \"${CLUSTER_ID}\",
  members: [
    { _id: 0, host: \"${SHRD_PRIME}.${DOMAIN_NAME}:${SHRD_PRIME_PORT}\", priority: 10 },
    { _id: 1, host: \"${SHRD_SERVERS[0]}.${DOMAIN_NAME}:${SHRD_SERVERS_PORT[0]}\" },
    { _id: 2, host: \"${SHRD_SERVERS[1]}.${DOMAIN_NAME}:${SHRD_SERVERS_PORT[1]}\" },
  ],
    });"
    
    SHRD_TOTAL=(
        "${SHRD_TOTAL[@]}"
        "\"${CLUSTER_ID}/${SHRD_PRIME}.${DOMAIN_NAME}:${SHRD_PRIME_PORT},${SHRD_SERVERS[0]}.${DOMAIN_NAME}:${SHRD_SERVERS_PORT[0]},${SHRD_SERVERS[1]}.${DOMAIN_NAME}:${SHRD_SERVERS_PORT[1]}\""
    )
done

while read -r LINE;
do
  [[ ${LINE} == SHARD_TOTAL=* ]] && DATA=`echo -e "SHARD_TOTAL=(${SHRD_TOTAL[@]})\n${DATA}"` || DATA=`echo -e "${LINE}\n${DATA}"`
done <<< `cat run-script/.env`

echo -e "${DATA}" > run-script/.env