#!/bin/bash

cd "$(dirname $0)"

source .env

for EACH_DATABASES in DATABASES/*;
do
    CURRENT_DB=${EACH_DATABASES#'DATABASES/'}
    COLLECTIONS_LIST=`sh -c "ls ${EACH_DATABASES}"`
    COLLECTIONS_LIST=(${COLLECTIONS_LIST//'.json'/})

    for EACH_COLLECTION in ${COLLECTIONS_LIST[@]};
    do
        mongosh \
        --quiet \
        --authenticationDatabase admin \
        --tls \
        --tlsCAFile="${NEW_DB_CAFILE}" \
        --tlsCertificateKeyFile="${NEW_DB_PEMKEYFILE}" \
        --username=${NEW_DB_USER} \
        --password=${NEW_DB_PASSWORD} \
        ${NEW_DB_HOST}:${NEW_DB_PORT} \
        --eval "sh.shardCollection(\"${CURRENT_DB}.${EACH_COLLECTION}\", {_id: 'hashed'})"

        mongoimport \
        --username=${NEW_DB_USER} \
        --password=${NEW_DB_PASSWORD} \
        --authenticationDatabase admin \
        --host ${NEW_DB_HOST}:${NEW_DB_PORT} \
        --ssl \
        --sslCAFile="${NEW_DB_CAFILE}" \
        --sslPEMKeyFile="${NEW_DB_PEMKEYFILE}" \
        --db ${CURRENT_DB} \
        --collection ${EACH_COLLECTION} \
        --mode=upsert \
        --file "DATABASES/${CURRENT_DB}/${EACH_COLLECTION}.json"
    done
done


