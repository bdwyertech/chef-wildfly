# Encoding: UTF-8

#
# Cookbook Name:: wildfly
# Resource:: loghandler
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
resource_name :wildfly_loghandler

property :handler,  String, name_property: true
property :app_name, String, required: true
property :type,     String, required: true
property :enabled,  String, default: 'true'
property :hostname, String, default: 'localhost'
property :port,     String, default: '514'
property :level,    String, default: 'ALL'
property :server_address, String, default: 'localhost'
property :syslog_format, String, default: 'RFC5424'
property :instance, String, required: false

#
# => Define the Default Resource Action
#
default_action :create

#
# => Create a Log Handler
#
action :create do
  if loghandler_exists?
    Chef::Log.info "#{new_resource} already exists - nothing to do."
  else
    converge_by("Create #{new_resource}") do
      create_loghandler
    end
  end
end

#
# => Delete a Log Handler
#
action :delete do
  if loghandler_exists?
    converge_by("Delete #{new_resource}") do
      delete_loghandler
    end
  else
    Chef::Log.info "#{new_resource} doesn't exist - can't delete."
  end
end

action_class do
  # => Include Helper Modules
  include WildFly::Helper

  def loghandler_exists?
    result = jb_cli("/subsystem=logging/#{new_resource.type}=#{new_resource.handler}:read-resource", new_resource.instance)
    result.exitstatus == 0
  end

  def create_loghandler
    params = [
      "hostname=#{new_resource.hostname}",
      "app-name=#{new_resource.app_name}",
    ].join(',')
    result = jb_cli("/subsystem=logging/#{new_resource.type}=#{new_resource.handler}:add(#{params})", new_resource.instance)
    result.exitstatus == 0
  end

  def delete_loghandler
    result = jb_cli("/subsystem=logging/#{new_resource.type}=#{new_resource.handler}:remove", new_resource.instance)
    result.exitstatus == 0
  end
end
