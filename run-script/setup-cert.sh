#!/bin/bash

bash keycert/run

for EACH_ITEM in keycert/servers/*/;
do
    SERVER=${EACH_ITEM#'keycert/servers/'}
    SERVER=${SERVER%'/'}
    SERVER_CONF_PATH=`find servers -name $SERVER`
    cp -r ${EACH_ITEM}cert ${SERVER_CONF_PATH}/
done