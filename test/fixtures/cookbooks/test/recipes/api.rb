# Encoding: UTF-8

include_recipe 'wildfly::default'

# => Set Transaction Node Identifier
wildfly_resource 'Transaction - Node Identifier' do
  path '/subsystem=transactions'
  parameters 'node-identifier' => node.name
  operation_headers 'allow-resource-service-restart' => true
  action :create
end

# => Ensure ASYNCIO for Messaging Journal (LibAIO)
wildfly_resource 'Messaging Journal - ASYNCIO' do
  path '/subsystem=messaging-activemq/server=default'
  parameters 'journal-type' => 'ASYNCIO'
  operation_headers 'allow-resource-service-restart' => true
  action :create
end

wildfly_resource 'Set Dummy System Property' do
  path ['system-property', 'DummyUrl']
  parameters value: 'ABC124'
  action :create
end

wildfly_resource 'PostBox' do
  path lazy { '/subsystem=mail/mail-session=postbox' }
  parameters 'jndi-name' => 'java:/mail/postbox',
             'from' => nil
  action :set
end

wildfly_resource 'PostBoxold' do
  path lazy { '/subsystem=mail/mail-session=postbox' }
  action :delete
end

wildfly_resource 'Adjust Root Log Handler' do
  path ['subsystem', 'logging', 'root-logger', 'ROOT']
  parameters handlers: %w(CONSOLE FILE)
  action :create
end

wildfly_resource 'Syslog Handler' do
  path ['subsystem', 'logging', 'syslog-handler', 'SYSLOG']
  parameters 'app-name' => 'TEST',
             'enabled'  => true,
             'hostname' => 'localhost',
             'level'    => 'ALL',
             'port'     => 514,
             'server-address' => 'test.syslog.local',
             'syslog-format' => 'RFC5424'
  action :create
end

wildfly_resource 'MySQL DataSource Test' do
  path ['subsystem', 'datasources', 'data-source', 'testds']
  parameters 'jndi-name' => 'java:jboss/datasource/testds',
             'connection-url' => 'jdbc:mysql://localhost:3306/testds',
             'driver-name' => 'mysql',
             'user-name' => 'dbusername',
             'password' => 'dbpassword',
             'min-pool-size' => '10',
             'max-pool-size' => '60',
             'pool-prefill' => true,
             'flush-strategy' => 'IdleConnections',
             'idle-timeout-minutes' => '2',
             'statistics-enabled' => true,
             'transaction-isolation' => 'TRANSACTION_REPEATABLE_READ',
             'background-validation' => true,
             'background-validation-millis' => '10000',
             'valid-connection-checker-class-name' => 'org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLValidConnectionChecker',
             'exception-sorter-class-name' => 'org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLExceptionSorter'
  action :create
end

#
# => XA Datasources are a PITA because of xa-datasource-properties
# => You can't feed xa-datasource-properties with the initial seed, they are a child-resource.
# => Solution is to bootstrap the XA source in a disabled state
wildfly_resource 'MySQL XA DataSource Test - Bootstrap' do
  path ['subsystem', 'datasources', 'xa-data-source', 'TestMySQLXADS']
  parameters 'jndi-name' => 'java:jboss/datasource/TestMySQLXADS',
             'driver-name' => 'mysql',
             'enabled' => false
  action :create_if_missing
end

# => Create the XA Parameters
wildfly_resource 'MySQL XA DataSource Test - URL' do
  path ['subsystem', 'datasources', 'xa-data-source', 'TestMySQLXADS', 'xa-datasource-properties', 'URL']
  parameters value: 'jdbc:mysql://localhost:3306/test'
  action :create
end

wildfly_resource 'MySQL XA DataSource Test' do
  path ['subsystem', 'datasources', 'xa-data-source', 'TestMySQLXADS']
  parameters 'jndi-name' => 'java:jboss/datasource/TestMySQLXADS',
             'driver-name' => 'mysql',
             'enabled' => true,
             'user-name' => 'dbusername',
             'password' => 'dbpassword',
             'allow-multiple-users' => true,
             'min-pool-size' => '10',
             'max-pool-size' => '60',
             'pool-prefill' => true,
             'flush-strategy' => 'IdleConnections',
             'idle-timeout-minutes' => '2',
             'statistics-enabled' => true,
             'transaction-isolation' => 'TRANSACTION_REPEATABLE_READ',
             'background-validation' => true,
             'background-validation-millis' => '10000',
             'valid-connection-checker-class-name' => 'org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLValidConnectionChecker',
             'exception-sorter-class-name' => 'org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLExceptionSorter'
  action :create
end

wildfly_resource 'DataSource Test2' do
  path ['subsystem', 'datasources', 'data-source', 'testds2']
  parameters 'jndi-name' => 'java:jboss/datasource/testds2',
             'connection-url' => 'jdbc:mysql://localhost:3306/testds2',
             'driver-name' => 'mysql',
             'user-name' => 'dbuser',
             'abc' => 'TEST' # => Should produce Unknown Key Error
  action :create
end

wildfly_resource 'DataSource PostgreSQL' do
  path ['subsystem', 'datasources', 'data-source', 'pgds1']
  parameters 'jndi-name' => 'java:jboss/datasource/pgds1',
             'connection-url' => 'jdbc:postgresql://localhost:5432/pgds1',
             'driver-name' => 'postgresql',
             'user-name' => 'dbuser',
             'valid-connection-checker-class-name' => 'org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLValidConnectionChecker',
             'exception-sorter-class-name' => 'org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLExceptionSorter'
  action :create
end

# => Provision the XA initially set to disabled
wildfly_resource 'DataSource PostgreSQL XA - Bootstrap' do
  path ['subsystem', 'datasources', 'xa-data-source', 'TestPostgreSQLXADS']
  parameters 'jndi-name' => 'java:jboss/datasource/TestPostgreSQLXADS',
             'driver-name' => 'postgresql',
             'enabled' => false
  action :create_if_missing
end

# => Create the XA Parameters
wildfly_resource 'DataSource PostgreSQL XA - URL' do
  path ['subsystem', 'datasources', 'xa-data-source', 'TestPostgreSQLXADS', 'xa-datasource-properties', 'URL']
  parameters value: 'jdbc:postgresql://localhost:5432/'
  action :create
end

wildfly_resource 'DataSource PostgreSQL XA' do
  path ['subsystem', 'datasources', 'xa-data-source', 'TestPostgreSQLXADS']
  parameters 'jndi-name' => 'java:jboss/datasource/TestPostgreSQLXADS',
             'driver-name' => 'postgresql',
             'user-name' => 'dbusername',
             'password' => 'dbpassword',
             'allow-multiple-users' => true,
             'min-pool-size' => '10',
             'max-pool-size' => '60',
             'pool-prefill' => true,
             'flush-strategy' => 'IdleConnections',
             'idle-timeout-minutes' => '2',
             'statistics-enabled' => true,
             'transaction-isolation' => 'TRANSACTION_REPEATABLE_READ',
             'background-validation' => true,
             'background-validation-millis' => '10000',
             'valid-connection-checker-class-name' => 'org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLValidConnectionChecker',
             'exception-sorter-class-name' => 'org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLExceptionSorter'
  action :create
end

wildfly_resource 'SMTP - Default' do
  path ['subsystem', 'mail', 'mail-session', 'default', 'server']
  parameters 'from' => 'mailuser@gmail.com'
  action :create
end

wildfly_resource 'SMTP - Default - Server Config' do
  path ['subsystem', 'mail', 'mail-session', 'default', 'server', 'smtp']
  parameters 'ssl' => true,
             'tls' => true,
             'username' => 'mailuser@gmail.com',
             'password' => 'mailpass'
  action :create
end

wildfly_resource 'SMTP - Default - Server Address' do
  path [
    'socket-binding-group',
    'standard-sockets',
    'remote-destination-outbound-socket-binding',
    'mail-smtp',
  ]
  parameters 'host' => 'smtp.gmail.com',
             'port' => 465
  action :create
end

# => Second Instance
wildfly 'wildfly2' do
  base_dir '/opt/wildfly2'
  launch_arguments [
    '-Dorg.jboss.as.logging.per-deployment=false',
  ]
  server_properties [
    'jboss.socket.binding.port-offset=2',
    'jboss.bind.address.management=0.0.0.0',
    # 'jboss.management.http.port=9990',
    # 'jboss.management.https.port=9993',
    'jboss.bind.address=0.0.0.0',
    # 'jboss.http.port=8080',
    # 'jboss.https.port=8443',
    'jboss.bind.address.private=0.0.0.0',
    'jboss.bind.address.unsecure=0.0.0.0',
    'jboss.default.multicast.address=230.1.2.3',
    'jboss.ajp.port=8009',
  ]
  action :install
end

wildfly_resource 'WF2 - SMTP - Default' do
  instance 'wildfly2'
  path ['subsystem', 'mail', 'mail-session', 'default', 'server']
  parameters 'from' => 'mailuser@gmail.com'
  action :create
end

%w(wildfly wildfly2).each do |wf|
  wildfly_resource "Set System Property - SystemName #{wf}" do
    instance wf
    path ['system-property', 'SystemName']
    parameters value: wf
    action :create
  end
end

wildfly_deploy_api 'ClusterDemo Deployment' do
  # => instance 'wildfly2'
  deploy_name 'cluster-demo-V1'
  runtime_name 'cluster-demo.war'
  parameters 'url' => 'https://github.com/bdwyertech/cluster-demo/releases/download/011218/cluster-demo.war'
  action [:install, :enable]
end

wildfly_deploy_api 'HelloWorld URL Deployment' do
  # => instance 'wildfly2'
  deploy_name 'HelloWorld-url-V5'
  runtime_name 'helloworld-url.war'
  parameters 'url' => 'https://github.com/efsavage/hello-world-war/raw/master/dist/hello-world.war'
end

# => File-Based Deployment
hw = remote_file 'helloworld' do
  source 'https://github.com/efsavage/hello-world-war/raw/master/dist/hello-world.war'
  path ::File.join(Chef::Config[:file_cache_path], 'hello-world.war')
  mode '0644'
  action :create
end

wildfly_deploy_api 'HelloWorld File Deployment' do
  deploy_name "HelloWorld-file-V#{Random.rand(10)}"
  runtime_name 'helloworld-file.war'
  parameters 'url' => 'file://' + hw.path
end

wildfly_deploy_api 'Sample' do
  deploy_name 'sample-v1'
  runtime_name 'sample.war'
  parameters 'url' => 'https://github.com/apcera/sample-apps/raw/master/example-java-war/sample.war'
end

wildfly_deploy_api 'Sample - Disable' do
  deploy_name 'sample-v3'
  runtime_name 'sample.war'
  action :disable
end

wildfly_deploy_api 'Sample2 - Disable' do
  deploy_name 'sample-v2'
  action :disable
end
