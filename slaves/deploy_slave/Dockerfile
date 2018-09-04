FROM alpine:latest

LABEL maintainer="anderm@netcompany.com"

ARG jenkins_slave_pass
ARG cli_url
ARG jnlp_user
ARG agent_name
ARG labels

USER root

ARG user=jenkins
ARG group=jenkins
ARG uid=10000
ARG gid=10000

ENV HOME /home/${user}

# Install docker
RUN apk add --update \
        openssh \
        git \
        docker \
        openrc \
        shadow \
        curl \
        openjdk8-jre \
        util-linux \
    && rc-update add docker boot \
    && rc-update add sshd \
    && rm -rf /var/cache/apk/*

# Jenkins User Config

RUN groupadd -g ${gid} ${group} \
    && useradd -c "Jenkins user" -d $HOME -u ${uid} -g ${gid} -m ${user} \
    && usermod -aG docker jenkins

# Create Agent Workspace
ARG VERSION=3.20
ARG AGENT_WORKDIR=/home/${user}/agent

ENV AGENT_WORKDIR=${AGENT_WORKDIR}

COPY jenkins-cli.jar /home/jenkins/jenkins-cli.jar

RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar \
        https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
    && chmod 755 /usr/share/jenkins \
    && chmod 644 /usr/share/jenkins/slave.jar \
    && chmod 644 /home/jenkins/jenkins-cli.jar

COPY run.sh /home/jenkins/run.sh

RUN chmod a+rwx /home/jenkins/run.sh

# Jenkins Private Key
COPY keys/ /usr/share/jenkins/ref/.ssh

# SSH Config
RUN echo "    IdentityFile $JENKINS_HOME/.ssh/id_rsa" >> /etc/ssh/ssh_config \
    && echo "    StrictHostKeyChecking no      " >> /etc/ssh/ssh_config \
    && chown -R jenkins /usr/share/jenkins/ref/.ssh \
    && chmod 600 /usr/share/jenkins/ref/.ssh/id_rsa \
    && chmod 600 /usr/share/jenkins/ref/.ssh/id_rsa.pub

# User Config
USER ${user}

ENV JENKINS_CLI_URL ${cli_url}
ENV JENKINS_SLAVE_CREDENTIALS jenkins-slave:${jenkins_slave_pass}

ENV JENKINS_AGENT_WORKDIR ${AGENT_WORKDIR}
ENV LABELS ${labels}

RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}

WORKDIR /home/${user}

ENTRYPOINT ["/home/jenkins/run.sh"]