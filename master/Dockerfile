FROM jenkinsci/jenkins:alpine

LABEL maintainer="mikkelsen.anders@gmail.com"

ARG jenkins_master_pass
ARG jenkins_slave_port
ARG jenkins_slave_pass
ARG jenkins_config_repo_url
ARG jenkins_config_repo_provider

USER root

# Install docker
RUN apk add --update \
        docker \
        openrc \
        shadow \
    && rc-update add docker boot \
    && usermod -aG docker jenkins \
    && rm -rf /var/cache/apk/*

# Jenkins Plugins List
COPY plugins.txt /usr/share/jenkins/ref/plugins/

# Install Plugins
RUN for i in $(seq 1 100); \
    do xargs /usr/local/bin/install-plugins.sh $(cat /usr/share/jenkins/ref/plugins/plugins.txt) \
    && s=0 \
    && break || s=$? && \
    rm -rfv /usr/share/jenkins/ref/plugins/*.lock \
    && sleep 1; \
    done; \
    (exit $s)

ENV JENKINS_USER jenkins
ENV JENKINS_PASS ${jenkins_master_pass}
ENV JENKINS_SLAVE_USER jenkins-slave
ENV JENKINS_SLAVE_PASS ${jenkins_slave_pass}
ENV JENKINS_CONFIG_REPO_URL ${jenkins_config_repo_url}
ENV JENKINS_CONFIG_REPO_PROVIDER ${jenkins_config_repo_provider}

ENV CURL_RETRY 200
ENV CURL_CONNECTION_TIMEOUT 600
ENV CURL_RETRY_DELAY 10

# Jenkins Start Script
COPY jenkins.sh /usr/local/bin/jenkins.sh

# Users
COPY users/default-user.groovy /usr/share/jenkins/ref/init.groovy.d/

# Config
COPY configs/scm-sync-configuration.xml /usr/share/jenkins/ref/scm-sync-configuration.xml.override

# Jenkins Private Key
COPY keys/ /usr/share/jenkins/ref/.ssh

# SSH Config
RUN echo "    IdentityFile $JENKINS_HOME/.ssh/id_rsa" >> /etc/ssh/ssh_config \
    && echo "    StrictHostKeyChecking no      " >> /etc/ssh/ssh_config \
    && chown -R jenkins /usr/share/jenkins/ref/.ssh \
    && chmod 600 /usr/share/jenkins/ref/.ssh/id_rsa \
    && chmod 600 /usr/share/jenkins/ref/.ssh/id_rsa.pub

# Jenkins Users Permission Config
RUN mkdir /tmp/gitwork \
    && chown jenkins /tmp/gitwork \
    && chown jenkins:jenkins /usr/local/bin/jenkins.sh \
    && chown jenkins:jenkins /usr/share/jenkins/ref/scm-sync-configuration.xml.override \
    && chmod +x /usr/local/bin/jenkins.sh

# Set Sync Config Repo
RUN sed -i "s,REPLACE_WITH_JENKINS_CONFIG_URL,$JENKINS_CONFIG_REPO_PROVIDER:$JENKINS_CONFIG_REPO_URL,g" /usr/share/jenkins/ref/scm-sync-configuration.xml.override

USER jenkins

ENV JENKINS_SLAVE_AGENT_PORT ${jenkins_slave_port}
ENV JAVA_OPTS "-Xmx8192m -Djenkins.install.runSetupWizard=false"
ENV JENKINS_OPTS ""

WORKDIR /var/jenkins_home

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=5s --retries=30 CMD curl -f localhost:8080/login || exit 1