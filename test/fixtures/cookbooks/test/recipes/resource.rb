# Encoding: UTF-8
# Resource Test

include_recipe 'wildfly::default'

service 'wildfly' do
  action :nothing
end

wildfly 'wildfly' do
  launch_arguments [
    '-Dorg.jboss.as.logging.per-deployment=false',
  ]
  server_properties [
    'jboss.bind.address.management=0.0.0.0',
  ]
  action :install
end

service 'wildfly2' do
  action :nothing
end

wildfly 'wildfly2' do
  base_dir '/opt/wildfly2'
  bind_management_http '9991'
  server_properties [
    'jboss.socket.binding.port-offset=1',
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

# include_recipe 'wildfly::mysql_connector' if node['wildfly']['mysql']['enabled']
# include_recipe 'wildfly::postgres_connector' if node['wildfly']['postgresql']['enabled']

wildfly_property 'Database URL' do
  property 'JdbcUrl'
  value 'jdbc:mysql://1.2.3.4:3306/testdbb'
  action :set
  notifies :restart, 'service[wildfly]', :delayed
end

wildfly_property 'Database URL 2' do
  property 'JdbcUrl'
  value 'jdbc:mysql://1.2.3.4:3306/testdbb123'
  action :set
  instance 'wildfly2'
  notifies :restart, 'service[wildfly2]', :delayed
end

wildfly_mysql_connector 'wildfly' do
  action :install
end

wildfly_postgres_connector 'wildfly' do
  action :install
end

wildfly_mysql_connector 'wildfly2' do
  base_dir '/opt/wildfly2'
  user 'wildfly2'
  group 'wildfly2'
  action :install
end

wildfly_attribute 'postbox jndi-name' do
  path '/subsystem=mail/mail-session="postbox"'
  parameter 'jndi-name'
  value 'java:/mail/postbox'
  action :set
end

wildfly_attribute 'postbox-escaped' do
  path '/subsystem=mail/mail-session="postbox-escaped"'
  parameter 'jndi-name'
  value ' WTF BRUHHH /345%20'
  action :set
end

wildfly_attribute 'postbox-noescaped' do
  path '/subsystem=mail/mail-session="postboxnoescaped"'
  parameter 'jndi-name'
  value ' WTF BRUHHH /345%200'
  enable_escape false
  action :set
end

wildfly_attribute 'postbox-noescaped' do
  path '/subsystem=mail/mail-session="postboxnoescapedsafe"'
  parameter 'jndi-name'
  value 'WTF'
  enable_escape false
  action :set
end

# wildfly_deploy 'helloworld' do
#   url 'https://github.com/efsavage/hello-world-war/raw/master/dist/hello-world.war'
# end

wildfly_datasource 'example' do
  jndiname 'java:jboss/datasource/example'
  drivername 'mysql'
  connectionurl 'jdbc:some://127.0.0.1/example'
end
