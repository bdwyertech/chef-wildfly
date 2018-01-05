# Encoding: UTF-8

# Cookbook Name:: wildfly
# Resource:: postgres_connector
#
# Copyright (C) 2018 Brian Dwyer - Intelligent Digital Services
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

# => Define the Resource Name
resource_name :wildfly_postgres_connector

# => Shorten Hashes
wildfly = node['wildfly']
postgresql = node['wildfly']['postgresql']

# => Define the Resource Properties
property :instance, String, required: false
property :base_dir, String, default: wildfly['base']
property :url,      String, default: postgresql['url']
property :checksum, String, required: false
property :user,     String, default: wildfly['user']
property :group,    String, default: wildfly['group']

#
# => Define the Default Resource Action
#
default_action :install

#
# => Install the PostGRES Connector
#
action :install do
  # => Create Postgres Directory
  directory postgres_dir do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
  end

  # => Download PostreSQL driver
  remote_file ::File.join(postgres_dir, postgres_jar) do
    source new_resource.url
    checksum new_resource.checksum if new_resource.checksum
    owner new_resource.user
    group new_resource.group
    action :create
  end

  # => Configure Postgres Module
  template ::File.join(postgres_dir, 'module.xml') do
    source 'module.xml.erb'
    user new_resource.user
    group new_resource.group
    mode '0644'
    variables(
      module_name: postgresql['mod_name'],
      resource_path: postgres_jar,
      module_dependencies: postgresql['mod_deps'],
      optional_dependencies: postgresql['mod_deps_optional']
    )
    action :create
  end

  if jdbc_driver_exists?
    Chef::Log.info "#{@new_resource} already configured - nothing to do."
  else
    converge_by("Configure #{@new_resource}") do
      deploy_jdbc_driver
    end
  end
end

#
# => Helpers
#
action_class.class_eval do
  # => Include Helper Modules
  include WildFly::Helper

  def jdbc_driver_exists?
    result = jb_cli('/subsystem=datasources/jdbc-driver=postgresql:read-resource')
    result.exitstatus.zero?
  end

  def deploy_jdbc_driver
    driver_params = [
      'driver-name=postgresql',
      'driver-module-name=org.postgresql',
      'driver-datasource-class-name=org.postgresql.Driver',
      'driver-xa-datasource-class-name=org.postgresql.xa.PGXADataSource'
    ].join(',')
    jb_cli("/subsystem=datasources/jdbc-driver=postgresql:add(#{driver_params})")
  end

  # => Shorten Postgres Directory Name
  def postgres_dir
    ::File.join(new_resource.base_dir, 'modules', 'system', 'layers', 'base', 'org', 'postgresql', 'main')
  end

  # => Postgres JAR Name
  def postgres_jar
    ::File.basename(new_resource.url)
  end

  # => Postgres Version Information
  def postgres_ver
    ::File.basename(new_resource.url, '.jar')
  end
end
