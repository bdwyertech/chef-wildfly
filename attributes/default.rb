# Encoding: UTF-8

# Copyright (C) 2018 Brian Dwyer - Intelligent Digital Services
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

# => Wildfly Configuration
# => Source
default['wildfly']['version'] = '11.0.0'
default['wildfly']['url'] = 'http://download.jboss.org/wildfly/11.0.0.Final/wildfly-11.0.0.Final.tar.gz'
default['wildfly']['checksum'] = 'a2f5fb4187369196003e31eb086f0a1f7bfc0645a3a61a53ed20ab5853481e71'

# => Base Directory
default['wildfly']['base'] = '/opt/wildfly'

# => Set Wildfly User & Group
default['wildfly']['user'] = 'wildfly'
default['wildfly']['group'] = 'wildfly'

# => Set Wildfly Service Name
default['wildfly']['service'] = 'wildfly'

# => Wildfly Deployment Type (standalone or domain)
default['wildfly']['mode'] = 'standalone'

# => Enforce Configuration (Force's redeployment of configuration, overwriting any local changes)
default['wildfly']['enforce_config'] = false

# => Standalone Mode Configuration
# => (standalone/ha.xml, standalone-full/ha/ha-aws.xml)
default['wildfly']['sa']['conf'] = 'standalone-full.xml'

# => Domain Mode Configuration
default['wildfly']['dom']['conf'] = 'domain.xml'
default['wildfly']['dom']['host_conf'] = 'host-master.xml'

# => Interface Configuration
# => Should probably put a proxy in front of these... Maybe NginX?
default['wildfly']['int']['mgmt']['bind'] = '0.0.0.0'
default['wildfly']['int']['mgmt']['http_port'] = '9990'
default['wildfly']['int']['mgmt']['https_port'] = '9993'

default['wildfly']['int']['pub']['bind'] = '0.0.0.0'
default['wildfly']['int']['pub']['http_port'] = '8080'
default['wildfly']['int']['pub']['https_port'] = '8443'

default['wildfly']['int']['wsdl']['bind'] = '0.0.0.0'
default['wildfly']['int']['ajp']['port'] = '8009'

# => Use this to offset all port bindings.  Each binding will be incremented by this value.
default['wildfly']['int']['port_binding_offset'] = '0'

# => Debugging Settings
default['wildfly']['jpda']['enabled'] = false
default['wildfly']['jpda']['port'] = '8787'

# => Console Log Location
default['wildfly']['log']['console_log'] = '/var/log/wildfly/console.log'
# => Enable Log Rotation on *.log in Console Log Directory
default['wildfly']['log']['rotation'] = true
# => Purge rotated logs older than this many days
default['wildfly']['log']['max_age'] = 375

# => Init Script Timeouts (Seconds)
default['wildfly']['initd']['startup_wait'] = '60'
default['wildfly']['initd']['shutdown_wait'] = '60'

# => Hardcode JAVA_HOME into init.d configuration.
# => Based on value of node['java']['java_home']
default['wildfly']['java']['enforce_java_home'] = true

default['wildfly']['install_java'] = true
