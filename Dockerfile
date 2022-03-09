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
		   clamav-unofficial-sigs \
                   util-linux-user && \
    microdnf clean all

ADD scripts/ /usr/local/bin/

ADD clamd/ /etc/clamd.d/

ADD clamav-unofficial-sigs.conf /etc/clamav-unofficial-sigs/

# Delete the default clam update cron jobs as we will be using custom tooling instead
RUN rm -f /etc/cron.d/clamav-update /etc/cron.d/clamav-unofficial-sigs

# Modify permissions needed to run as the clamupdate user
RUN chown -R clamupdate:clamupdate /etc/clamav-unofficial-sigs && \
    chown -R clamupdate:clamupdate /usr/local/sbin /var/log/clamav-unofficial-sigs /var/lib/clamav-unofficial-sigs && \
    chown -R clamupdate:clamupdate /var/lib/clamav/ && \
    chown clamupdate:clamupdate /usr/sbin/clamav-unofficial-sigs.sh && \
    chown clamupdate:clamupdate /usr/bin/freshclam

# Change shell to the clamupdate user
RUN /usr/bin/chsh -s /bin/bash clamupdate

# Edit clamav config file settings
# Add necessary permissions to add arbitrary user
# Make symlinks to /secret custom signature databases and config
RUN sed -i -e 's/reload_dbs="yes"/reload_dbs="no"/' /etc/clamav-unofficial-sigs/clamav-unofficial-sigs.conf && \
    sed -i -e 's/--max-time "$curl_max_time" //' /usr/sbin/clamav-unofficial-sigs.sh && \
    sed -i -e 's/--connect-timeout "$curl_connect_timeout"//' /usr/sbin/clamav-unofficial-sigs.sh && \
    rm -f /etc/cron.d/clamav-update /etc/cron.d/clamav-unofficial-sigs && \
    chmod -R g+rwX /etc/passwd /etc/group

# run as clamupdate user
USER 999

# Start processes
CMD /usr/local/bin/start.sh
