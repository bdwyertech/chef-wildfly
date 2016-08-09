# Encoding: UTF-8
# rubocop:disable LineLength
#
# Copyright (C) 2014 Brian Dwyer - Intelligent Digital Services
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

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
