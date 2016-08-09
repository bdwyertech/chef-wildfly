# encoding: UTF-8
# rubocop:disable LineLength
#
# Cookbook Name:: wildfly
# Recipe:: postgres_connector
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

# => Make PostgreSQL Information Retrievable
node.default['wildfly']['postgresql']['version'] = ::File.basename(node['wildfly']['postgresql']['url'], '.jar')
node.default['wildfly']['postgresql']['jar'] = "#{node['wildfly']['postgresql']['version']}.jar"

# => Shorten Hashes
wildfly = node['wildfly']
postgresql = node['wildfly']['postgresql']

# => Shorten Postgres Directory Name
postgres_dir = ::File.join(wildfly['base'], 'modules', 'system', 'layers', 'base', 'org', 'postgresql', 'main')

# => Create Postgres Directory
directory postgres_dir do
  owner wildfly['user']
  group wildfly['group']
  mode 0755
  recursive true
end

# => Download PostreSQL driver
remote_file "#{postgres_dir}/#{postgresql['jar']}" do
  source postgresql['url']
  checksum postgresql['checksum']
  action :create
end

# => Configure PostgreSQL module
template ::File.join(postgres_dir, 'module.xml') do
  source 'module.xml.erb'
  user wildfly['user']
  group wildfly['group']
  mode '0644'
  variables(
    module_name: postgresql['mod_name'],
    resource_path: postgresql['jar'],
    module_dependencies: postgresql['mod_deps']
  )
  action :create
  notifies :restart, "service[#{wildfly['service']}]", :delayed
end
