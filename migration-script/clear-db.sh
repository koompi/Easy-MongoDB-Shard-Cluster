#!/bin/bash

source .env

DATABASES=`mongosh \
--quiet \
--authenticationDatabase admin \
--tls \
--tlsCAFile="${NEW_DB_CAFILE}" \
--tlsCertificateKeyFile="${NEW_DB_PEMKEYFILE}" \
--username=${NEW_DB_USER} \
--password=${NEW_DB_PASSWORD} \
${NEW_DB_HOST}:${NEW_DB_PORT} \
--eval='show dbs'`

DATABASES=`echo ${DATABASES//[0-9.0-9]} | sed 's/.iB//g'`

for DATABASE in ${DATABASES[@]};
do
    [[ ${DATABASE} == "admin" ]] ||
    [[ ${DATABASE} == "local" ]] ||
    [[ ${DATABASE} == "config" ]] &&
    continue;
    
    mongosh \
    --quiet \
    --authenticationDatabase admin \
    --tls \
    --tlsCAFile="${NEW_DB_CAFILE}" \
    --tlsCertificateKeyFile="${NEW_DB_PEMKEYFILE}" \
    --username=${NEW_DB_USER} \
    --password=${NEW_DB_PASSWORD} \
    ${NEW_DB_HOST}:${NEW_DB_PORT}/${DATABASE} \
    --eval="db.dropDatabase()"
done