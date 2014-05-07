# encoding: UTF-8
# rubocop:disable LineLength
#
# => MySQL Database Configuration

# => MySQL ConnectorJ
default['wildfly']['mysql']['enabled'] = true
default['wildfly']['mysql']['url'] = 'http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.30.tar.gz'
default['wildfly']['mysql']['checksum'] = '1986baca293f998f9ecfe8a56e6e832825048a9c466cc5b5ed91940407f1210d'

# => MySQL ConnectorJ JDBC Module Name
default['wildfly']['mysql']['mod_name'] = 'com.mysql'
# => MySQL ConnectorJ Module Dependencies
default['wildfly']['mysql']['mod_deps'] = ['javax.api', 'javax.transaction.api']
