# Encoding: UTF-8

include_recipe 'wildfly::default'

wildfly_property 'Database URL' do
  property 'JdbcUrl'
  value 'jdbc:mysql://1.2.3.4:3306/testdbb'
  action :set
  notifies :restart, 'service[wildfly]', :delayed
end

wildfly_datasource 'example' do
  jndiname 'java:jboss/datasource/example'
  drivername 'mysql'
  connectionurl 'jdbc:some://127.0.0.1/example'
end

wildfly_attribute 'postbox jndi-name' do
  path '/subsystem=mail/mail-session=postbox'
  parameter 'jndi-name'
  value 'java:/mail/postbox'
  action :set
end

wildfly_attribute 'postbox-escaped' do
  path '/subsystem=mail/mail-session=postbox-escaped'
  parameter 'jndi-name'
  value ' WTF BRUHHH /345%20'
  action :set
end

wildfly_loghandler 'loghandler' do
  type 'syslog-handler'
  hostname '1.2.3.4'
  app_name 'my.app'
end
