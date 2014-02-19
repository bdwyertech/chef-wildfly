# encoding: UTF-8
#
# Cookbook Name:: wildfly
# Recipe:: install
#
# Copyright (C) 2014 Brian Dwyer - Intelligent Digital Services
# 
# All rights reserved - Do Not Redistribute
#

# => Shorten Hashes
wildfly = node['wildfly']

# => Update System
include_recipe 'apt' if platform?('ubuntu', 'debian')
include_recipe 'yum' if platform_family?('rhel')

# => Create Wildfly System User
user wildfly['user'] do
  comment 'Wildfly'
  shell '/bin/bash'
  supports manage_home: true
  action [:create, :lock]
end

# => Create Wildfly Directory
directory wildfly['base'] do
  owner wildfly['user']
  group wildfly['group']
  mode 0755
  recursive true
end

# => Download Wildfly Tarball
remote_file "#{Chef::Config[:file_cache_path]}/#{wildfly['version']}.tar.gz" do
  source wildfly['url']
  checksum wildfly['checksum']
  action :create
  notifies :run, "bash[Extract Wildfly]", :immediately
end

# => Extract Wildfly
bash 'Extract Wildfly' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  tar xzf #{wildfly['version']}.tar.gz -C #{wildfly['base']} --strip 1
  chown #{wildfly['user']}:#{wildfly['group']} -R #{wildfly['base']}
  EOF
  action :nothing
end

# Deploy Init Script
template File.join('etc', 'init.d', wildfly['service']) do
  source 'wildfly-init-redhat.sh.erb'
  user 'root'
  group 'root'
  mode '0755'
  variables({
    user: wildfly['user']
  })
end

# => Configure Wildfly Standalone - Interfaces
template File.join(wildfly['base'], 'standalone', 'configuration', 'standalone.xml') do
  source 'standalone.xml.erb'
  user wildfly['user']
  group wildfly['group']
  mode '0644'
  variables({
    mgmt_int: wildfly['int']['mgmt']['bind'],
    mgmt_http_port: wildfly['int']['mgmt']['http_port'],
    mgmt_https_port: wildfly['int']['mgmt']['https_port'],
    pub_int: wildfly['int']['pub']['bind'],
    pub_http_port: wildfly['int']['pub']['http_port'],
    pub_https_port: wildfly['int']['pub']['https_port'],
    wsdl_int: wildfly['int']['wsdl']['bind'],
    ajp_port: wildfly['int']['ajp']['port'],
    smtp_host: wildfly['smtp']['host'],
    smtp_port: wildfly['smtp']['port'],
    smtp_ssl: wildfly['smtp']['ssl'],
    smtp_user: wildfly['smtp']['username'],
    smtp_pass: wildfly['smtp']['password'],
    acp: wildfly['acp']
  })
  notifies :restart, "service[wildfly]", :delayed
end

# => Configure Wildfly Standalone - MGMT Users
template File.join(wildfly['base'], 'standalone', 'configuration', 'mgmt-users.properties') do
  source 'mgmt-users.properties.erb'
  user wildfly['user']
  group wildfly['group']
  mode '0600'
  variables({
    mgmt_users: wildfly['users']['mgmt']
  })
end

# => Start the Wildfly Service
service wildfly['service'] do
  action :start
end
