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
postgresql = node['wildfly']['postgresql']

# => Define the Resource Properties
property :instance, String, required: false
property :base_dir, String, default: lazy { WildFly::Helper.wildfly_cfg(instance)['dir'] }
property :url,      String, default: postgresql['url']
property :checksum, String, default: postgresql['checksum']
property :user,     String, default: lazy { WildFly::Helper.wildfly_cfg(instance)['user'] }
property :group,    String, default: lazy { WildFly::Helper.wildfly_cfg(instance)['group'] }
property :api,      [FalseClass, TrueClass], default: true

#
# => Define the Default Resource Action
#
default_action :install

#
# => Install the PostgreSQL Connector
#
action :install do
  # => Create PostgreSQL Directory
  directory postgres_dir do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
  end

  # => Download PostgreSQL driver
  remote_file ::File.join(postgres_dir, postgres_jar) do
    source new_resource.url
    checksum new_resource.checksum if new_resource.checksum
    owner new_resource.user
    group new_resource.group
    action :create
  end

  # => Configure PostgreSQL Module
  template ::File.join(postgres_dir, 'module.xml') do
    source 'module.xml.erb'
    user new_resource.user
    group new_resource.group
    cookbook 'wildfly'
    mode '0644'
    variables(
      module_name: 'org.postgresql',
      resource_path: postgres_jar,
      module_dependencies: postgresql['mod_deps'],
      optional_dependencies: postgresql['mod_deps_optional']
    )
    action :create
  end

  if new_resource.api
    wildfly_resource 'PostgreSQL JDBC Driver' do
      instance new_resource.instance
      path '/subsystem=datasources/jdbc-driver=postgresql'
      parameters 'driver-name' => 'postgresql',
                 'driver-module-name' => 'org.postgresql',
                 'driver-class-name' => 'org.postgresql.Driver',
                 'driver-datasource-class-name' => 'org.postgresql.ds.PGConnectionPoolDataSource',
                 'driver-xa-datasource-class-name' => 'org.postgresql.xa.PGXADataSource'
    end
  elsif jdbc_driver_exists?
    Chef::Log.info "#{new_resource} already configured - nothing to do."
  else
    converge_by("Configure #{new_resource}") do
      deploy_jdbc_driver
    end
  end
end

#
# => Helpers
#
action_class do
  # => Include Helper Modules
  include WildFly::Helper

  def jdbc_driver_exists?
    result = jb_cli('/subsystem=datasources/jdbc-driver=postgresql:read-resource', new_resource.instance)
    result.exitstatus == 0
  end

  def deploy_jdbc_driver
    driver_params = [
      'driver-name=postgresql',
      'driver-module-name=org.postgresql',
      'driver-class-name=org.postgresql.Driver',
      'driver-datasource-class-name=org.postgresql.ds.PGConnectionPoolDataSource',
      'driver-xa-datasource-class-name=org.postgresql.xa.PGXADataSource',
    ].join(',')
    jb_cli("/subsystem=datasources/jdbc-driver=postgresql:add(#{driver_params})", new_resource.instance)
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
