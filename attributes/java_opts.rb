# Encoding: UTF-8
# rubocop:disable LineLength

# => Default Wildfly Java Options
# =>  JAVA_OPTS="-Xms64m -Xmx512m -XX:MaxPermSize=256m -Djava.net.preferIPv4Stack=true"
# =>  JAVA_OPTS="$JAVA_OPTS -Djboss.modules.system.pkgs=$JBOSS_MODULES_SYSTEM_PKGS -Djava.awt.headless=true"

# => The defaults are adjustable here
default['wildfly']['java_opts']['xmx'] = '512m'
default['wildfly']['java_opts']['xms'] = '64m'
default['wildfly']['java_opts']['xx_maxpermsize'] = '256m'
default['wildfly']['java_opts']['preferipv4'] = 'true'
default['wildfly']['java_opts']['headless'] = 'true'

# => Specify other java options in this space-deliniated array.
default['wildfly']['java_opts']['other'] = %w(

)
