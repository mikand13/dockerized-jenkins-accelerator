#!/usr/bin/env sh

# Configure git
git config --global user.email "jenkins@tollpost.no" \
    && git config --global user.name  "jenkins"

export JENKINS_AGENT_NAME=`uuidgen`
JENKINS_URL=$JENKINS_CLI_URL/computer/deploy-$JENKINS_AGENT_NAME/slave-agent.jnlp
EXECUTORS=1
USERID=${USER}

cat <<EOF | java -jar /home/jenkins/jenkins-cli.jar -s $JENKINS_CLI_URL -auth $JENKINS_SLAVE_CREDENTIALS create-node deploy-$JENKINS_AGENT_NAME
<slave>
  <name>deploy-${JENKINS_AGENT_NAME}</name>
  <description></description>
  <remoteFS>${JENKINS_AGENT_WORKDIR}</remoteFS>
  <numExecutors>${EXECUTORS}</numExecutors>
  <mode>NORMAL</mode>
  <launcher class="hudson.slaves.JNLPLauncher" />
  <label>${LABELS}</label>
  <nodeProperties/>
  <userId>${USERID}</userId>
</slave>
EOF

exec java $JAVA_OPTS $JNLP_PROTOCOL_OPTS -jar /usr/share/jenkins/slave.jar -noReconnect -jnlpUrl $JENKINS_URL -jnlpCredentials $JENKINS_SLAVE_CREDENTIALS