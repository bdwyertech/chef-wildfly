# Encoding: UTF-8

#
# Cookbook Name:: wildfly
# Resource:: datasource
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
resource_name :wildfly_datasource

# => Define the Resource Properties
property :dsname,        String, name_property: true
property :jndiname,      String
property :drivername,    String
property :connectionurl, String
property :username,      [String, NilClass]
property :password,      [String, NilClass]
property :instance,      String, required: false

#
# => Define the Default Resource Action
#
default_action :create

#
# => Set an Attribute
#
action :create do
  if datasource_exists?
    Chef::Log.info "#{new_resource} already exists - nothing to do."
  else
    converge_by("Create #{new_resource}") do
      create_datasource
    end
  end
end

action :delete do
  if datasource_exists?
    converge_by("Delete #{new_resource}") do
      delete_datasource
    end
  else
    Chef::Log.info "#{new_resource} doesn't exist - can't delete."
  end
end

action_class do
  # => Include Helper Modules
  include WildFly::Helper

  def datasource_exists?
    result = jb_cli("/subsystem=datasources/data-source=#{new_resource.dsname.gsub('/', '\/')}:read-resource", new_resource.instance)
    result.exitstatus == 0
  end

  def create_datasource
    params = %W(
      --name=#{new_resource.dsname}
      --jndi-name=#{new_resource.jndiname}
      --driver-name=#{new_resource.drivername}
      --connection-url=#{new_resource.connectionurl}
    )
    params << "--user-name=#{new_resource.username}" if new_resource.username
    params << "--password=#{new_resource.password}" if new_resource.password

    jb_cli("data-source add #{params.join(' ')}", new_resource.instance) unless datasource_exists?
  end

  def delete_datasource
    jb_cli("data-source remove --name=#{new_resource.dsname}", new_resource.instance) if datasource_exists?
  end
end
