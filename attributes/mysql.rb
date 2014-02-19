# encoding: UTF-8
#
# => MySQL Database Configuration

# => MySQL ConnectorJ
default['wildfly']['mysql']['enabled'] = true
default['wildfly']['mysql']['url'] = 'http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.29.tar.gz'
default['wildfly']['mysql']['checksum'] = '04ad83b655066b626daaabb9676a00f6b4bc43f0c234cbafafac1209dcf1be73'

# => MySQL ConnectorJ JDBC Module Name
default['wildfly']['mysql']['mod_name'] = 'com.mysql'
# => MySQL ConnectorJ Module Dependencies
default['wildfly']['mysql']['mod_deps'] = ['javax.api', 'javax.transaction.api']
