import jenkins.model.*
import hudson.security.*

def env = System.getenv()

def jenkins = Jenkins.getInstance()
jenkins.setSecurityRealm(new HudsonPrivateSecurityRealm(false))
jenkins.setAuthorizationStrategy(new GlobalMatrixAuthorizationStrategy())

def user = jenkins.getSecurityRealm().createAccount(env.JENKINS_USER, env.JENKINS_PASS)
user.save()

def slaveUser = jenkins.getSecurityRealm().createAccount(env.JENKINS_SLAVE_USER, env.JENKINS_SLAVE_PASS)
slaveUser.save()

jenkins.getAuthorizationStrategy().add(Jenkins.ADMINISTER, env.JENKINS_USER)
jenkins.getAuthorizationStrategy().add(Jenkins.ADMINISTER, env.JENKINS_SLAVE_USER)
jenkins.save()