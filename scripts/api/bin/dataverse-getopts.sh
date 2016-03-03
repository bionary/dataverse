#!/bin/bash
## script source to coordinate command line options/parameters

invoked=$_
OPTIND=1

OPT_c="collection1"
OPT_g="/home/glassfish/glassfish4"
OPT_h="localhost"
OPT_m="localhost"
OPT_p="8983"
OPT_s="localhost"
OPT_u=0
## Do not set a default for OPT_z!
## Presence of OPT_z is tested to see if this is a zookeeper/solrCloud backed installation.
## Do not set a default for OPT_f!
## Presence of OPT_f is tested to see if dataverse should use a non-standard directory path to store uploaded files.

while getopts :c:f:g:h:m:p:s:u:v:z: FLAG; do
  case $FLAG in
    c)  #set option solr-collection "c"
      OPT_c=$OPTARG
      ;;
    f)  #set option filesdir "f"
      OPT_f=$OPTARG
      ;;
    g)  #set option gfdir "g"
      OPT_g=$OPTARG
      ;;
    h)  #set option hostname "h"
      OPT_h=$OPTARG
      ;;
    m)  #set option mailserver "m"
      OPT_m=$OPTARG
      ;;
    p)  #set option solr-port "p"
      OPT_p=$OPTARG
      ;;
    s)  #set option solr-host "s"
      OPT_s=$OPTARG
      ;;
    u)  #set option useSolrViaHTTPS "u"
      OPT_u=$OPTARG
      ;;
    v)  #set output verbosity level "v"
      OUTPUT_VERBOSITY=$OPTARG
      ;;
    z)  #set option solrCloud-zookeeper "z"
      OPT_z=$OPTARG
      ;;
    \?) #unknown option
      echo "Unknown option: -$OPTARG" >&2
      ;;
    :)  #valid option requires adjacent argument
      echo "Option -$OPTARG requires an argument." >&2
      if [ $invoked -ne $0 ]; then
        return 1
      else
        exit 1
      fi
      ;;
  esac
done
