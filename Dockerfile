FROM jenkins/jenkins:latest

USER root
RUN /usr/local/bin/install-plugins.sh git mstest matrix-auth workflow-aggregator docker-workflow blueocean credentials-binding

ENV JENKINS_USER admin
ENV JENKINS_PASS admin

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY master/executors.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY master/default-user.groovy /usr/share/jenkins/ref/init.groovy.d/
USER root
COPY scripts/installs.sh /installs.sh
RUN chmod +x /installs.sh && /bin/bash /installs.sh

VOLUME /var/jenkins_home
