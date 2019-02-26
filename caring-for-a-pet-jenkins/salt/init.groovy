// A single craptastic script to provision the demo jenkins instance.
// Definitely not ready for production.

import jenkins.model.Jenkins
import jenkins.model.JenkinsLocationConfiguration
import jenkins.model.*
import hudson.security.*
import java.util.logging.Logger
import hudson.security.csrf.DefaultCrumbIssuer

def logger = Logger.getLogger("")
def j = Jenkins.instance
def location = j.getExtensionList('jenkins.model.JenkinsLocationConfiguration')[0]

location.url = 'http://192.168.30.30:8080/'
location.adminAddress = 'demo@example.com'

j.systemMessage = 'Jenkins and Nomad demo'
j.setNumExecutors(0)
j.slaveAgentPort = 50000

// plugins

def pluginManager = j.getPluginManager()
def updateCenter = j.getUpdateCenter()
updateCenter.updateAllSites()

def plugins = ["git", "pipeline", "docker-plugin", "nomad", "blueocean"]

plugins.each {
  if (!pluginManager.getPlugin(it)) {
    def plugin = updateCenter.getPlugin(it)
    if (plugin) {
      logger.info("Installing " + it)
      def installFuture = plugin.deploy()
      while(!installFuture.isDone()) {
        logger.info("Waiting for plugin install: " + it)
        sleep(3000)
      }
    }
  }
}

// security


j.setCrumbIssuer(new DefaultCrumbIssuer(true))
Set<String> agentProtocolsList = ['JNLP4-connect', 'Ping']
j.setAgentProtocols(agentProtocolsList)

// login

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("demo", "demo")
j.setSecurityRealm(hudsonRealm)

def strategy = new hudson.security.FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
j.setAuthorizationStrategy(strategy)

j.save()
