# encoding: UTF-8
# rubocop:disable LineLength
#
# Cookbook Name:: wildfly
# Recipe:: mysql_connector
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

# => Make MySQL Connector/J Information Retrievable
node.default['wildfly']['mysql']['version'] = ::File.basename(node['wildfly']['mysql']['url'], '.tar.gz')
node.default['wildfly']['mysql']['jar'] = "#{node['wildfly']['mysql']['version']}-bin.jar"

# => Shorten Hashes
wildfly = node['wildfly']
mysql = node['wildfly']['mysql']

# => Shorten Connector/J Directory Name
connectorj_dir = ::File.join(wildfly['base'], 'modules', 'system', 'layers', 'base', 'com', 'mysql', 'main')

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
  notifies :run, 'bash[Extract ConnectorJ]', :immediately
end

# => Extract MySQL Connector/J
bash 'Extract ConnectorJ' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  tar xzf #{mysql['version']}.tar.gz -C #{connectorj_dir} --strip 1 --no-anchored --wildcards #{mysql['jar']}
  chown #{wildfly['user']}:#{wildfly['group']} -R #{connectorj_dir}/../
  EOF
  not_if { ::File.exist?(::File.join(connectorj_dir, mysql['jar'])) }
end

# => Configure MySQL Connector/J Module
template ::File.join(connectorj_dir, 'module.xml') do
  source 'module.xml.erb'
  user wildfly['user']
  group wildfly['group']
  mode '0644'
  variables(
    module_name: mysql['mod_name'],
    resource_path: mysql['jar'],
    module_dependencies: mysql['mod_deps']
  )
  action :create
  notifies :restart, "service[#{wildfly['service']}]", :delayed
end
