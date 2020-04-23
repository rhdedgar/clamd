# /usr/local/bin/start.sh will start the service

#FROM openshifttools/oso-centos7-ops-base:latest
FROM registry.access.redhat.com/ubi8/ubi-minimal

# Pause indefinitely if asked to do so.
ARG OO_PAUSE_ON_BUILD
RUN test "$OO_PAUSE_ON_BUILD" = "true" && while sleep 10; do true; done || :


# Install clam server utilities and signature updater
RUN microdnf install -y wget && \
    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    rpm -i epel-release-latest-8.noarch.rpm && \
    microdnf install -y clamav \
		   clamav-update \
		   clamd \
		   clamav-unofficial-sigs && \
    microdnf clean all

ADD scripts/ /usr/local/bin/

ADD clamd/ /etc/clamd.d/

# Delete the default clam update cron jobs as we will be using custom tooling instead
RUN rm -f /etc/cron.d/clamav-update /etc/cron.d/clamav-unofficial-sigs

# Start processes
CMD /usr/local/bin/start.sh
