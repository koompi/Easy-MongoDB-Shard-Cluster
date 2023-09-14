#!/bin/bash

cd "$(dirname $0)"

source .env

OLD_DB_LISTS=`mongosh \
--quiet \
--authenticationDatabase admin \
--username=${OLD_DB_USER} \
--password=${OLD_DB_PASSWORD} \
${OLD_DB_HOST}:${OLD_DB_PORT} \
--eval "show dbs"`;

OLD_DB_LISTS=(`echo ${OLD_DB_LISTS//[0-9.0-9]} | sed 's/.iB//g'`)

for EACH_DATABASES in ${OLD_DB_LISTS[@]};
do
    [[ ${EACH_DATABASES} == "admin" ]] ||
    [[ ${EACH_DATABASES} == "local" ]] ||
    [[ ${EACH_DATABASES} == "config" ]] &&
    continue;
    
    mkdir -p DATABASES/${EACH_DATABASES}
    
    COLLECTION_LISTS=(`mongosh \
        --quiet \
        --authenticationDatabase admin \
        --username=${OLD_DB_USER} \
        --password=${OLD_DB_PASSWORD} \
        ${OLD_DB_HOST}:${OLD_DB_PORT}/${EACH_DATABASES} \
    --eval "show collections"`);
    
    for EACH_COLLECTION in ${COLLECTION_LISTS[@]};
    do
        mongoexport \
        --host=${OLD_DB_HOST} \
        --port=${OLD_DB_PORT} \
        --username=${OLD_DB_USER} \
        --password=${OLD_DB_PASSWORD} \
        --authenticationDatabase=admin \
        --db ${EACH_DATABASES} \
        --collection ${EACH_COLLECTION} \
        --jsonFormat=canonical \
        --out="DATABASES/${EACH_DATABASES}/${EACH_COLLECTION}.json"
    done
done
