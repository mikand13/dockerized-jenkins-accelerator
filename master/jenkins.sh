#! /bin/bash -e

# Configure git
git config --global user.email "jenkins@container" && git config --global user.name  "jenkins"

GIT_SSH_COMMAND='ssh -i /usr/share/jenkins/ref/.ssh/id_rsa' git clone $JENKINS_CONFIG_REPO_URL /tmp/gitwork \
    && cp -r /tmp/gitwork/. $JENKINS_HOME \
    && rm -r /tmp/gitwork

if [ -f $JENKINS_HOME/scm-sync-configuration.xml ]; then
    cp $JENKINS_HOME/scm-sync-configuration.xml /usr/share/jenkins/ref/scm-sync-configuration.xml.override
fi

: "${JENKINS_WAR:="/usr/share/jenkins/jenkins.war"}"
: "${JENKINS_HOME:="/var/jenkins_home"}"
touch "${COPY_REFERENCE_FILE_LOG}" || { echo "Can not write to ${COPY_REFERENCE_FILE_LOG}. Wrong volume permissions?"; exit 1; }
echo "--- Copying files at $(date)" >> "$COPY_REFERENCE_FILE_LOG"
find /usr/share/jenkins/ref/ \( -type f -o -type l \) -exec bash -c '. /usr/local/bin/jenkins-support; for arg; do copy_reference_file "$arg"; done' _ {} +

# if `docker run` first argument start with `--` the user is passing jenkins launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then

  # read JAVA_OPTS and JENKINS_OPTS into arrays to avoid need for eval (and associated vulnerabilities)
  java_opts_array=()
  while IFS= read -r -d '' item; do
    java_opts_array+=( "$item" )
  done < <([[ $JAVA_OPTS ]] && xargs printf '%s\0' <<<"$JAVA_OPTS")

  jenkins_opts_array=( )
  while IFS= read -r -d '' item; do
    jenkins_opts_array+=( "$item" )
  done < <([[ $JENKINS_OPTS ]] && xargs printf '%s\0' <<<"$JENKINS_OPTS")

  exec java -Duser.home="$JENKINS_HOME" "${java_opts_array[@]}" -jar ${JENKINS_WAR} "${jenkins_opts_array[@]}" "$@"
fi

# As argument is not jenkins, assume user want to run his own process, for example a `bash` shell to explore this image
exec "$@"