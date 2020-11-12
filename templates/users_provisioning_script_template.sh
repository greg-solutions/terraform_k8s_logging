#!/bin/bash
# Script creates admin and readonly users/roles.
# Run it from elasticsearch pod or any pod that have access to elasticsearch after elasticsearch and kibana are provisioned.

# create admin user
curl --user ${ELASTIC_USERNAME}:${ELASTIC_PASSWORD} -d '{"password":"${KIBANA_ADMIN_USER_PASS}", "roles":"superuser"}' -H "Content-Type: application/json" -X POST http://${ELASTIC_HOST_NAME}:${ELASTIC_PORT}/_security/user/${KIBANA_ADMIN_USER_NAME}

# create role for readonly user
curl --user ${ELASTIC_USERNAME}:${ELASTIC_PASSWORD} -d '{ "indices" : [{"names" : ["${ENV_INDEX_PREFIX}-*"],"privileges" : ["read","read_cross_cluster"],"allow_restricted_indices" : false}],"applications" : [{"application" : "kibana-.kibana","privileges" : ["read"],"resources" : ["*"]}],"run_as" : [ ],"metadata" : { },"transient_metadata" : {"enabled" : true}}' -H "Content-Type: application/json" -X POST http://${ELASTIC_HOST_NAME}:${ELASTIC_PORT}/_security/role/kibana_readonly_role

# create readonly user
curl --user ${ELASTIC_USERNAME}:${ELASTIC_PASSWORD} -d '{"password":"${KIBANA_READONLY_USER_PASS}", "roles":"kibana_readonly_role"}' -H "Content-Type: application/json" -X POST http://${ELASTIC_HOST_NAME}:${ELASTIC_PORT}/_security/user/${KIBANA_READONLY_USER_NAME}
