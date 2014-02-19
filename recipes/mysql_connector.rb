# encoding: UTF-8
#
# Cookbook Name:: wildfly
# Recipe:: mysql_connector
#
# Copyright (C) 2014 Brian Dwyer - Intelligent Digital Services
# 
# All rights reserved - Do Not Redistribute
#

# => Make MySQL Connector/J Information Retrievable
node.default['wildfly']['mysql']['version'] = File.basename(node['wildfly']['mysql']['url'], '.tar.gz')
node.default['wildfly']['mysql']['jar'] = "#{node['wildfly']['mysql']['version']}-bin.jar"

# => Shorten Hashes
wildfly = node['wildfly']
mysql = node['wildfly']['mysql']

# => Shorten Connector/J Directory Name
connectorj_dir = File.join(wildfly['base'], 'modules', 'system', 'layers', 'base', 'com', 'mysql', 'main' )

# => Create MySQL Connector/J Directory
directory connectorj_dir do
  owner wildfly['user']
  group wildfly['group']
  mode 0755
  recursive true
end

# => Download MySQL Connector/J Tarball
remote_file "#{Chef::Config[:file_cache_path]}/#{mysql['version']}.tar.gz" do
  source mysql['url']
  checksum mysql['checksum']
  action :create
end

# => Extract MySQL Connector/J
bash 'Extract ConnectorJ' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  tar xzf #{mysql['version']}.tar.gz -C #{connectorj_dir} --strip 1 --no-anchored --wildcards #{mysql['jar']}
  chown #{wildfly['user']}:#{wildfly['group']} -R #{connectorj_dir}/../
  EOF
end

# => Configure MySQL Connector/J Module
template File.join(connectorj_dir, 'module.xml') do
  source 'module.xml.erb'
  user wildfly['user']
  group wildfly['group']
  mode '0644'
  variables({
    module_name: mysql['mod_name'],
    resource_path: mysql['jar'],
    module_dependencies: mysql['mod_deps']
  })
  action :create
end


# => Configure MySQL Datasource
template File.join(wildfly['base'], 'standalone', 'configuration', 'mgmt-users.properties') do
  source 'mysql-ds.erb'
  user wildfly['user']
  group wildfly['group']
  mode '0600'
  variables({
    jndi_name: 'MySQLDB',
    mysql_server: wildfly['users']['mgmt'],
    mysql_port: wildfly['users']['mgmt'],
    mysql_db_name: wildfly['users']['mgmt'],
    mysql_user: wildfly['users']['mgmt'],
    mysql_pass: wildfly['users']['mgmt'],
    mysql_pool_min: '5',
    mysql_pool_min: '20',
    mysql_timeout: '5'
  })
  action :nothing
end
