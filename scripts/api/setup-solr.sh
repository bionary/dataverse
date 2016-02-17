#!/bin/bash

if [[ -z ${OUTPUT_VERBOSITY} ]]; then OUTPUT_VERBOSITY='1'; fi

## OPT_* variables come from /dataverse/scripts/api/bin/dataverse-getopts.sh
. "./bin/dataverse-getopts.sh"

#### Set output verbosity ####
## *_CMD and _IF_* command variables are set in /dataverse/scripts/api/bin/util-set-verbosity.sh
. "./bin/util-set-verbosity.sh"

$_IF_TERSE echo "Configuring solr to index dataverse collection: ${OPT_c} ..."

SOLR_URI="${OPT_u}://${OPT_s}:${OPT_p}/solr/${OPT_c}"
DATAVERSE_URI="http://${OPT_h}:8080/api"

$_IF_VERBOSE echo "Deleting all index data for Solr Collection $OPT_c at $SOLR_URI"
$_IF_VERBOSE curl ${SOLR_URI}/update?commit=true -H "Content-type: application/json" -X POST -d "{\"delete\": { \"query\":\"*:*\"}}"

$_IF_VERBOSE echo "Setting dataverse servers SolrHostColonPort property to ${OPT_s}:${OPT_p}"
$_IF_VERBOSE curl -X PUT -d ${OPT_s}:${OPT_p} ${DATAVERSE_URI}/admin/settings/:SolrHostColonPort
$_IF_VERBOSE echo ""