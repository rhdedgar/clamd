# /usr/local/bin/start.sh will start the service

FROM registry.access.redhat.com/ubi8/ubi:latest

# Pause indefinitely if asked to do so.
ARG OO_PAUSE_ON_BUILD
RUN test "$OO_PAUSE_ON_BUILD" = "true" && while sleep 10; do true; done || :

# Install clam server utilities and signature updater
RUN yum install -y clamav-server \
		   clamav-scanner \
		   clamav-unofficial-sigs && \
    yum clean all

ADD scripts/ /usr/local/bin/

# Delete the default clam update cron jobs as we will be using custom tooling instead
RUN rm -f /etc/cron.d/clamav-update /etc/cron.d/clamav-unofficial-sigs

# Start processes
CMD /usr/local/bin/start.sh
