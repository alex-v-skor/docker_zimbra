#!/bin/sh

if [ ! -d "/opt/zimbra-install" ]; then
  if [ "$?" -eq 0 ]; then
    echo "Installation successful"
    echo ""
    echo "You can access now to your Zimbra Collaboration Server"
    echo "Admin Console: https://${HOSTNAME}.${DOMAIN}:7071"
    echo "Web Client: https://${HOSTNAME}.${DOMAIN}"
  fi
  exit 0
else
  # Zimbra installation and configuration script
  /opt/install.sh
fi




