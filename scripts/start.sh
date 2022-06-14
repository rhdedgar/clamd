#!/bin/bash -e

echo "clamd container v0.0.11"

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

if [ "$UPDATE_ONLY" = "true" ] ; then
  echo
  echo "The UPDATE_ONLY variable has been set. This container will attempt to keep the pod's shared volume updated with new clam DBs without starting clamd."
  echo
  echo 'Updating ClamAV official and unofficial signatures every 12 hours'
  echo '----------------'
    /usr/local/bin/ops-run-in-loop 43200 /usr/bin/freshclam 2>&1 &
    sleep 300
    /usr/local/bin/ops-run-in-loop 43200 /usr/sbin/clamav-unofficial-sigs.sh
fi

echo This container hosts the following applications:
echo
echo '/usr/sbin/clamd'
echo
echo 'Start clamd in the foreground so we can easily check status with oc logs'
while true; do
  /usr/sbin/clamd -c /etc/clamd.d/scan.conf --foreground=yes
  echo "clamd exited with code $?."
  echo "sleeping for 10 seconds before restarting clamd."
  sleep 10
done
