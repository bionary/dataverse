#!/bin/bash

## setup-getopts.sh provides a common set of shell parameter parsing OPT_* variables for dataverse/environment configuration
SOURCE "../api/setup-getopts.sh"

INSTALL_ARGS="--force -y --hostname $OPT_h --gfdir $OPT_g --mailserver $OPT_m"
if [ -z "$OPT_z" ]; then
  INSTALL_ARGS="$INSTALL_ARGS --solrcollection $OPT_c --solrport $OPT_p --solrhost $OPT_s --solrurlschema $OPT_u"
else
  INSTALL_ARGS="$INSTALL_ARGS --solrzookeeper $OPT_z"
fi

WAR=/dataverse/target/dataverse*.war
if [ ! -f $WAR ]; then
  echo "no war file found... building"
  echo "Installing nss on CentOS 6 to avoid java.security.KeyException while building war file: https://github.com/IQSS/dataverse/issues/2744"
  yum install -y nss
  su $SUDO_USER -s /bin/sh -c "cd /dataverse && mvn package"
fi

cd /dataverse/scripts/installer
./install $INSTALL_ARGS