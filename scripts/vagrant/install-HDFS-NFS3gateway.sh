#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "$0 must be run by a super user.\nInstallation failed!" >&2
  exit 1
fi

if [[ -z ${OUTPUT_VERBOSITY} ]];then OUTPUT_VERBOSITY='1'; fi

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

$_IF_TERSE echo "Installing HDFS NFSv3 Gateway using verbosity level: ${OUTPUT_VERBOSITY}"

#### Install hadoop-hdfs-nfs3 using yum ####
if [[ ! -e /etc/yum.repos.d/cloudera-cdh5.repo ]]; then
  $_IF_INFO echo "Adding cloudera yum repo"
  $_IF_VERBOSE pushd /etc/yum.repos.d
  $_IF_VERBOSE $CURL_CMD -L -O https://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/cloudera-cdh5.repo
fi

yum_packages=("hadoop-hdfs-nfs3" "nfs-utils" "nfs-utils-lib")
for yummyPkg in "${yum_packages[@]}"; do
  $_IF_TERSE echo "Installing $yummyPkg"
  $_IF_VERBOSE $YUM_CMD install -y $yummyPkg
done

$_IF_TERSE echo "HDFS-NFS Gateway installed"
