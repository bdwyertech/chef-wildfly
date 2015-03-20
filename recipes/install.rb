# encoding: UTF-8
# rubocop:disable LineLength
#
# Cookbook Name:: wildfly
# Recipe:: install
#
# Copyright (C) 2014 Brian Dwyer - Intelligent Digital Services
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
#

# => Shorten Hashes
wildfly = node['wildfly']

# => Update System
include_recipe 'apt' if platform?('ubuntu', 'debian')
include_recipe 'yum' if platform_family?('rhel')

# Create file to indicate user upgrade change (Applicable to 0.1.16 to 0.1.17 upgrade)
file ::File.join(wildfly['base'], '.chef_useracctchange') do
  action :touch
  only_if { ::File.exist?(::File.join(wildfly['base'], '.chef_deployed')) && `getent passwd #{wildfly['user']} | cut -d: -f6`.chomp != wildfly['base'] }
  notifies :stop, "service[#{wildfly['service']}]", :immediately
end

# => Create Wildfly System User
user wildfly['user'] do
  comment 'Wildfly System User'
  home wildfly['base']
  shell '/sbin/nologin'
  system true
  action [:create, :lock]
end

# => Create Wildfly Group
group wildfly['group'] do
  append true
  members wildfly['user']
  action :create
  only_if { wildfly['user'] != wildfly['group'] }
end

# => Create Wildfly Directory
directory wildfly['base'] do
  owner wildfly['user']
  group wildfly['group']
  mode 0755
  recursive true
end

# => Ensure LibAIO Present for Java NIO Journal
case node['platform_family']
when 'rhel'
  package 'libaio' do
    action :install
  end
when 'debian'
  package 'libaio1' do
    action :install
  end
end

# => Download Wildfly Tarball
remote_file "#{Chef::Config[:file_cache_path]}/#{wildfly['version']}.tar.gz" do
  source wildfly['url']
  checksum wildfly['checksum']
  action :create
  notifies :run, 'bash[Extract Wildfly]', :immediately
end

# => Extract Wildfly
bash 'Extract Wildfly' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  tar xzf #{wildfly['version']}.tar.gz -C #{wildfly['base']} --strip 1
  chown #{wildfly['user']}:#{wildfly['group']} -R #{wildfly['base']}
  rm -f #{::File.join(wildfly['base'], '.chef_deployed')}
  EOF
  action :nothing
end

# Deploy Init Script
template ::File.join(::File::SEPARATOR, 'etc', 'init.d', wildfly['service']) do
  case node['platform_family']
  when 'rhel'
    source 'wildfly-init-redhat.sh.erb'
  when 'debian'
    source 'wildfly-init-debian.sh.erb'
  end
  user 'root'
  group 'root'
  mode '0755'
end

# Deploy Service Configuration
template ::File.join(::File::SEPARATOR, 'etc', 'default', 'wildfly.conf') do
  source 'wildfly.conf.erb'
  user 'root'
  group 'root'
  mode '0644'
end

# => Configure Wildfly Standalone - Interfaces
template ::File.join(wildfly['base'], 'standalone', 'configuration', wildfly['sa']['conf']) do
  source "#{wildfly['sa']['conf']}.erb"
  user wildfly['user']
  group wildfly['group']
  mode '0644'
  variables(
    port_binding_offset: wildfly['int']['port_binding_offset'],
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
    acp: wildfly['acp'],
    s3_access_key: wildfly['aws']['s3_access_key'],
    s3_secret_access_key: wildfly['aws']['s3_secret_access_key'],
    s3_bucket: wildfly['aws']['s3_bucket']
  )
  notifies :restart, "service[#{wildfly['service']}]", :delayed
  only_if { !::File.exist?(::File.join(wildfly['base'], '.chef_deployed')) || wildfly['enforce_config'] }
end

# => Configure Wildfly Standalone - MGMT Users
template ::File.join(wildfly['base'], 'standalone', 'configuration', 'mgmt-users.properties') do
  source 'mgmt-users.properties.erb'
  user wildfly['user']
  group wildfly['group']
  mode '0600'
  variables(
    mgmt_users: wildfly['users']['mgmt']
  )
end

# => Configure Wildfly Standalone - Application Users
template ::File.join(wildfly['base'], 'standalone', 'configuration', 'application-users.properties') do
  source 'application-users.properties.erb'
  user wildfly['user']
  group wildfly['group']
  mode '0600'
  variables(
    app_users: wildfly['users']['app']
  )
end

# => Configure Wildfly Standalone - Application Roles
template ::File.join(wildfly['base'], 'standalone', 'configuration', 'application-roles.properties') do
  source 'application-roles.properties.erb'
  user wildfly['user']
  group wildfly['group']
  mode '0600'
  variables(
    app_roles: wildfly['roles']['app']
  )
end

# => Configure Java Options - Standalone
template ::File.join(wildfly['base'], 'bin', 'standalone.conf') do
  source 'standalone.conf.erb'
  user wildfly['user']
  group wildfly['group']
  mode '0644'
  variables(
    xms: wildfly['java_opts']['xms'],
    xmx: wildfly['java_opts']['xmx'],
    maxpermsize: wildfly['java_opts']['xx_maxpermsize'],
    preferipv4: wildfly['java_opts']['preferipv4'],
    headless: wildfly['java_opts']['headless']
  )
  notifies :restart, "service[#{wildfly['service']}]", :delayed
end

# => Configure Java Options - Domain
template ::File.join(wildfly['base'], 'bin', 'domain.conf') do
  source 'domain.conf.erb'
  user wildfly['user']
  group wildfly['group']
  mode '0644'
  variables(
    xms: wildfly['java_opts']['xms'],
    xmx: wildfly['java_opts']['xmx'],
    maxpermsize: wildfly['java_opts']['xx_maxpermsize'],
    preferipv4: wildfly['java_opts']['preferipv4'],
    headless: wildfly['java_opts']['headless']
  )
  notifies :restart, "service[#{wildfly['service']}]", :delayed
  only_if { wildfly['mode'] == 'domain' }
end

# => Configure Lograte for Wildfly
template 'Wildfly Logrotate Configuration' do
  path ::File.join(::File::SEPARATOR, 'etc', 'logrotate.d', node['wildfly']['service'])
  source 'logrotate.erb'
  owner 'root'
  group 'root'
  mode '0644'
  only_if { ::File.directory?(::File.join(::File::SEPARATOR, 'etc', 'logrotate.d')) && wildfly['log']['rotation'] }
  action :create
end

# Create file to indicate deployment and prevent recurring configuration deployment
file ::File.join(wildfly['base'], '.chef_deployed') do
  owner wildfly['user']
  group wildfly['group']
  action :create_if_missing
end

# => Start the Wildfly Service
service wildfly['service'] do
  action [:enable, :start]
end
