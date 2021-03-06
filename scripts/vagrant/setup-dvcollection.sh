#!/bin/bash

if [[ -z ${OUTPUT_VERBOSITY} ]];then OUTPUT_VERBOSITY='1'; fi
if [[ -z ${DVCOLLECTION_NAME} ]];then DVCOLLECTION_NAME='dvcollection'; fi
if [[ -z ${SOLR_INSTALL_DIR} ]]; then SOLR_INSTALL_DIR='/opt'; fi
if [[ -z ${SOLR_OWNER} ]]; then SOLR_OWNER='solr'; fi

_usage() {
  echo "Usage: $0 [chirsv]"
  echo "Supported options:"
  echo "  -c     Solr collection name for main dataverse index. [${DVCOLLECTION_NAME}]"
  echo "  -h     Print this help message."
  echo "  -i     Directory in which to extract th solr installation. [${SOLR_INSTALL_DIR}]"
  echo "  -r     Number of replicas of each collection fragement created in the solrCloud. [1]"
  echo "  -s     Number of shards to fragment the collection into on the solrCloud. [1]"
  echo "  -u     User the solr service runs as. [${SOLR_OWNER}]"
  echo "  -v     Verbosity of this installation script (0-3). [${OUTPUT_VERBOSITY}]"
  echo ""
}

while getopts :c:h:i:r:s:u:v: FLAG; do
  case $FLAG in
    c)
      DVCOLLECTION_NAME=$OPTARG
      ;;
    h)  #print help
      _usage
      exit 0
      ;;
    i)  #set option solr install directory
      SOLR_INSTALL_DIR=$OPTARG
      ;;
    r)  #set output verbosity level
      DVCOLLECTION_REPLICAS=$OPTARG
      ;;
    s)  #set output verbosity level
      DVCOLLECTION_SHARDS=$OPTARG
      ;;
    u)  #solr runs as SOLR_OWNER
      ## user will be created if not exists
      SOLR_OWNER=$OPTARG
      ;;
    v)  #set output verbosity level
      OUTPUT_VERBOSITY=$OPTARG
      ;;
    :)  #valid option requires adjacent argument
      echo "Option $OPTARG requires an adjacent argument" >&2
      exit 1;
      ;;
    *)
      ;;
  esac
done

#### Set output verbosity ####
## *_CMD and _IF_* command variables are set in /dataverse/scripts/api/bin/util-set-verbosity.sh
if [[ -e "/dataverse/scripts/api/bin/util-set-verbosity.sh" ]]; then
  . "/dataverse/scripts/api/bin/util-set-verbosity.sh"
elif [[ -e "../api/bin/util-set-verbosity.sh" ]]; then
  . "../api/bin/util-set-verbosity.sh"
elif [[ -e "./util-set-verbosity.sh" ]]; then
  . "./util-set-verbosity.sh"
fi

$_IF_TERSE echo "Creating Solr collection ${DVCOLLECTION_NAME} to use with dataverse"

#### Check for bin/solr availability ####
if [[ -x ${SOLR_INSTALL_DIR}/solr/bin/solr ]]; then
  $_IF_VERBOSE echo "found solr executable at ${SOLR_INSTALL_DIR}/solr/bin/solr"
  _solr=${SOLR_INSTALL_DIR}/solr/bin/solr
elif ( type -p solr >/dev/null 2>&1 ); then
  $_IF_VERBOSE echo "found solr executable in PATH" 
  _solr=solr
else
  echo "Unable to find solr executable!" >&2
  echo "Solr Collection setup has failed!" >&2
  return 1
fi

$_IF_VERBOSE echo "Checking for custom solr collection configurations"
if [[ -e /dataverse/conf/solr/5.x ]]; then
  DVCOLLECTION_CONF_DIR='/dataverse/conf/solr/5.x'
elif [[ -e /conf/solr/5.x ]]; then
  DVCOLLECTION_CONF_DIR='/conf/solr/5.x'
elif [[ -e ./conf/solr/5.x ]]; then
  DVCOLLECTION_CONF_DIR='./conf/solr/5.x'
elif [[ -e ../../../conf/solr/5.x ]]; then
  DVCOLLECTION_CONF_DIR='../../../conf/solr/5.x'
else
  echo "Collection conf directory could not be found!" >&2
  echo "Solr Collection setup has failed!" >&2
  return 1;
fi

$_IF_VERBOSE echo "found at ${DVCOLLECTION_CONF_DIR}"
$_IF_INFO echo "Creating Solr collection ${DVCOLLECTION_NAME}"
_create_collection_cmd="create -c '${DVCOLLECTION_NAME}' -d '${DVCOLLECTION_CONF_DIR}'"

if [[ -n ${DVCOLLECTION_SHARDS} ]]; then
  $_IF_INFO echo "Fragmenting ${DVCOLLECTION_NAME} across ${DVCOLLECTION_SHARDS} solrCloud nodes"
  _create_collection_cmd="${_create_collection_cmd} -shards ${DVCOLLECTION_SHARDS}"
fi

if [[ -n ${DVCOLLECTION_REPLICAS} ]]; then
  $_IF_INFO echo "Replicating each ${DVCOLLECTION_NAME} shard 'fragment' across ${DVCOLLECTION_REPLICAS} solrCloud cores"
  _create_collection_cmd="${_create_collection_cmd} -replicationFactor ${DVCOLLECTION_REPLICAS}"
fi

eval "sudo -u $SOLR_OWNER SOLR_INCLUDE=/etc/default/solr.in.sh $_solr ${_create_collection_cmd}"

$_IF_TERSE echo "Solr collection ${DVCOLLECTION_NAME} established"