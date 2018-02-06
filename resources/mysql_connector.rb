# Encoding: UTF-8

#
# Cookbook Name:: wildfly
# Resource:: mysql_connector
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
resource_name :wildfly_mysql_connector

# => Shorten Hashes
mysql = node['wildfly']['mysql']

# => Define the Resource Properties
property :instance, String, required: false
property :base_dir, String, default: lazy { WildFly::Helper.wildfly_cfg(instance)['dir'] }
property :url,      String, default: mysql['url']
property :checksum, String, default: mysql['checksum']
property :user,     String, default: lazy { WildFly::Helper.wildfly_cfg(instance)['user'] }
property :group,    String, default: lazy { WildFly::Helper.wildfly_cfg(instance)['group'] }
property :api,      [FalseClass, TrueClass], default: true

#
# => Define the Default Resource Action
#
default_action :install

#
# => Install the MySQL Connector
#
action :install do
  # => Create MySQL Connector/J Directory
  directory connectorj_dir do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
  end

  # => Download MySQL Connector/J Tarball
  remote_file ::File.join(Chef::Config[:file_cache_path], ::File.basename(new_resource.url)) do
    source new_resource.url
    checksum new_resource.checksum if new_resource.checksum
    action :create
    notifies :run, 'bash[Extract ConnectorJ]', :immediately
    not_if { ::File.exist?(::File.join(connectorj_dir, connectorj_jar)) }
  end

  # => Extract MySQL Connector/J
  bash 'Extract ConnectorJ' do
    cwd Chef::Config[:file_cache_path]
    code <<-EOF
    rm -f #{::File.join(connectorj_dir, 'mysql*.jar')}
    tar xzf #{connectorj_ver}.tar.gz -C #{connectorj_dir} --strip 1 --no-anchored --wildcards #{connectorj_jar}
    chown #{new_resource.user}:#{new_resource.group} -R #{connectorj_dir}/../
    EOF
    not_if { ::File.exist?(::File.join(connectorj_dir, connectorj_jar)) }
  end

  # => Configure MySQL Connector/J Module
  template ::File.join(connectorj_dir, 'module.xml') do
    source 'module.xml.erb'
    user new_resource.user
    group new_resource.group
    cookbook 'wildfly'
    mode '0644'
    variables(
      module_name: 'com.mysql',
      resource_path: connectorj_jar,
      module_dependencies: mysql['mod_deps'],
      optional_dependencies: mysql['mod_deps_optional']
    )
    action :create
  end

  if new_resource.api
    wildfly_resource 'MySQL Connector/J JDBC Driver' do
      instance new_resource.instance
      path '/subsystem=datasources/jdbc-driver=mysql'
      parameters 'driver-name' => 'mysql',
                 'driver-module-name' => 'com.mysql',
                 'driver-class-name' => 'com.mysql.jdbc.Driver',
                 # => com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource
                 'driver-datasource-class-name' => 'com.mysql.jdbc.jdbc2.optional.MysqlDataSource',
                 'driver-xa-datasource-class-name' => 'com.mysql.jdbc.jdbc2.optional.MysqlXADataSource'
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
    result = jb_cli('/subsystem=datasources/jdbc-driver=mysql:read-resource', new_resource.instance)
    result.exitstatus == 0
  end

  def deploy_jdbc_driver
    driver_params = [
      'driver-name=mysql',
      'driver-module-name=com.mysql',
      'driver-class-name=com.mysql.jdbc.Driver',
      'driver-datasource-class-name=com.mysql.jdbc.jdbc2.optional.MysqlDataSource',
      'driver-xa-datasource-class-name=com.mysql.jdbc.jdbc2.optional.MysqlXADataSource',
    ].join(',')
    jb_cli("/subsystem=datasources/jdbc-driver=mysql:add(#{driver_params})", new_resource.instance)
  end

  # => Shorten Connector/J Directory Name
  def connectorj_dir
    ::File.join(new_resource.base_dir, 'modules', 'system', 'layers', 'base', 'com', 'mysql', 'main')
  end

  # => Connector/J JAR Name
  def connectorj_jar
    connectorj_ver + '-bin.jar'
  end

  # => Connector/J Version Information
  def connectorj_ver
    ::File.basename(new_resource.url, '.tar.gz')
  end
end
