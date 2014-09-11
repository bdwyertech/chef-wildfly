# encoding: UTF-8
# rubocop:disable LineLength, SpecialGlobalVars, MethodLength
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

require 'etc'

# Support whyrun
def whyrun_supported?
  false
end

action :create do
  if @current_resource_exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_loghandler
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      delete_loghandler
    end
  else
    Chef::Log.info "#{ @current_resource } doesn't exist - can't delete."
  end
end

def load_current_resource
  @current_resource_exists = true if loghandler_exists?(@new_resource.name)
end

private

def loghandler_exists?(name)
  `su #{node['wildfly']['user']} -s /bin/bash -c "#{node['wildfly']['base']}/bin/jboss-cli.sh -c ' /subsystem=logging/#{new_resource.type}=#{name}:read-resource'"`

  $?.exitstatus == 0
end

def create_loghandler
  bash 'install_datasource' do
    user node['wildfly']['user']
    cwd node['wildfly']['base']
    code <<-EOH
      bin/jboss-cli.sh -c command="/subsystem=logging/#{new_resource.type}=#{new_resource.name}:add(hostname=#{new_resource.hostname},app-name=#{new_resource.app_name})"
    EOH
  end
end

def delete_loghandler
  bash 'remove_datasource' do
    user node['wildfly']['user']
    cwd node['wildfly']['base']
    code <<-EOH
      `su #{node['wildfly']['user']} -s /bin/bash -c "#{node['wildfly']['base']}/bin/jboss-cli.sh -c ' /subsystem=logging/#{new_resource.type}=#{name}:remove'"`
    EOH
  end
end
