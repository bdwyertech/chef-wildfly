# encoding: UTF-8
#
# => MySQL Datasource Definitions
# => Stored as an array of hashes

# => Pool values are # of connections.
# => Connections are kept open until they time out.
# => Timeout is in minutes.
# => *** Check the timeout values on the MySQL DB ***
# => ***   Make sure the timeout here is lower!   ***

#default['wildfly']['mysql']['jndi']['datasources'] = [
#	{
#		jndi_name => 'java:jboss/datasources/test',
#		server => '127.0.0.1',
#		port => '3306',
#		db_name => 'test',
#		db_user => 'test_user',
#		db_pass => 'test_pass',
#		pool_min => '5',
#		pool_max => '20',
#		timeout => '5'
#	},
#	{
#		jndi_name => 'java:jboss/datasources/test2',
#		server => '127.0.0.1',
#		port => '3306',
#		db_name => 'test2',
#		db_user => 'test_user',
#		db_pass => 'test_pass',
#		pool_min => '5',
#		pool_max => '20',
#		timeout => '5'
#	}
#]
