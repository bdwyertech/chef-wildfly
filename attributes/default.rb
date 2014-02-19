# encoding: UTF-8
#
# => Wildfly Configuration

# => Source
default['wildfly']['version'] = '8.0.0'
default['wildfly']['url'] = 'http://download.jboss.org/wildfly/8.0.0.Final/wildfly-8.0.0.Final.tar.gz'
default['wildfly']['checksum'] = '7316100a8dae90a74fb96f9d70d758daee71ebd70d5ed680307082f010d6f3a9'

# => Base Directory
default['wildfly']['base'] = '/opt/wildfly'

# => Set Wildfly User & Group
default['wildfly']['user'] = 'wildfly'
default['wildfly']['group'] = 'wildfly'

# => Set Wildfly Service Name
default['wildfly']['service'] = 'wildfly'

# => Wildfly Deployment Type
# => (standalone/ha, standalone-full/ha)
default['wildfly']['type'] = 'standalone'

# => Should probably put a proxy in front of these... Maybe NginX?
default['wildfly']['int']['mgmt']['bind'] = '0.0.0.0'
default['wildfly']['int']['mgmt']['http_port'] = '9990'
default['wildfly']['int']['mgmt']['https_port'] = '9993'

default['wildfly']['int']['pub']['bind'] = '0.0.0.0'
default['wildfly']['int']['pub']['http_port'] = '8080'
default['wildfly']['int']['pub']['https_port'] = '8443'

default['wildfly']['int']['wsdl']['bind'] = '0.0.0.0'
default['wildfly']['int']['ajp']['port'] = '8009'

# => SMTP Settings
default['wildfly']['smtp']['host'] = 'localhost'
default['wildfly']['smtp']['port'] = '25'
