#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "$0 must be run by a super user.\nInstallation failed!" >&2
  exit 1
fi

if [[ -z ${OUTPUT_VERBOSITY} ]];then OUTPUT_VERBOSITY='1'; fi
if [[ -z ${ZOOKEEPER_CFG} ]]; then ZOOKEEPER_CFG='server.1=localhost:2888:3888'; fi

ZOOKEEPER_SERVER_ID='1'

_usage() {
  echo "\nUsage: $0 \[hv\]"
  echo "\nSupported options:"
  echo "  -h     Print this help message."
  echo "  -v     Verbosity of this installation script \(0-3\). \[${OUTPUT_VERBOSITY}\]"
  echo "\n"
}

while getopts :v:h FLAG; do
  case $FLAG in
    h)  #print help
      _usage
      exit 0
      ;;
    v)  #set output verbosity level "v"
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
elif [[ -e "../../api/bin/util-set-verbosity.sh" ]]; then
  . "../../api/bin/util-set-verbosity.sh"
elif [[ -e "./util-set-verbosity.sh" ]]; then
  . "./util-set-verbosity.sh"
else
  CURL_CMD='curl'
fi

$_IF_TERSE echo "Configuring HDFS NFSv3 Gateway using verbosity level: ${OUTPUT_VERBOSITY}"

if [[ -e "/etc/hadoop/conf/hdfs-site.xml" ]]; then
  _hdfsSiteConf=/etc/hadoop/conf/hdfs-site.xml
else
  echo "Could not locate the hdfs-site.xml configuration file." >&2
  echo "Configuration Failed!" >&2
  exit 1
fi

if [[ -e "/etc/hadoop/conf/core-site.xml" ]]; then
  _coreSiteConf=/etc/hadoop/conf/core-site.xml
else
  echo "Could not locate the core-site.xml configuration file." >&2
  echo "Configuration Failed!" >&2
  exit 1
fi

$_IF_INFO "Adding NFS Gateway configurations to ${_hdfsSiteConf}"
$_IF_VERBOSE sed -i 's:</configuration>::' $_hdfsSiteConf
echo "  <property>
    <name>dfs.namenode.accesstime.precision</name>
    <value>3600000</value>
    <description>The access time for an HDFS file is precise up to this value. The default value is 1 hour.
    Setting a value of 0 disables access times for HDFS.</description>
  </property>
  <property>
    <name>dfs.nfs3.dump.dir</name>
    <value>/tmp/.hdfs-nfs</value>
  </property>
</configuration>
" >> $_hdfsSiteConf

$_IF_INFO "Adding NFS Gateway configurations to ${_coreSiteConf}"
$_IF_VERBOSE sed -i 's:</configuration>::' $_coreSiteConf
echo "  <property>
   <name>hadoop.proxyuser.hdfs.groups</name>
   <value>*</value>
   <description>
     Set this to '*' to allow the gateway user to proxy any group.
   </description>
  </property>
  <property>
    <name>hadoop.proxyuser.hdfs.hosts</name>
    <value>*</value>
    <description>
     Set this to '*' to allow requests from any hosts to be proxied.
    </description>
  </property>
</configuration>
" >> $_coreSiteConf

$_IF_TERSE echo "HDFS-NFS Gateway Configured. Please start the hadoop-hdfs-nfs3 service to enable this gateway"
