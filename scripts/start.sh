#!/bin/bash -e

echo "clamd container v0.0.2"

# This is useful so we can debug containers running inside of OpenShift that are
# failing to start properly.

if [ "$OO_PAUSE_ON_START" = "true" ] ; then
  echo
  echo "This container's startup has been paused indefinitely because OO_PAUSE_ON_START has been set."
  echo
  while true; do
    sleep 10    
  done
fi

echo This container hosts the following applications:
echo
echo '/usr/sbin/clamd'
echo
echo 'start clamd in the foreground so we can easily check status with oc logs'
/usr/sbin/clamd -c /etc/clamd.d/scan.conf --foreground=yes
