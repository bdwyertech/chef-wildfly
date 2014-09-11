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
  true
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_logcategory
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      delete_logcategory
    end
  else
    Chef::Log.info "#{ @current_resource } doesn't exist - can't delete."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::WildflyLogcategory.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.use_parent_handlers(@new_resource.use_parent_handlers)
  @current_resource.level(@new_resource.level)
  #  @current_resource.handlers(@new_resource.handlers)
  @current_resource.exists = true if logcategory_exists?(@current_resource.name)
  # TODO: Set @current_resource port properties from command output
end

private

def logcategory_exists?(name)
  `su #{node['wildfly']['user']} -s /bin/bash -c "#{node['wildfly']['base']}/bin/jboss-cli.sh -c ' /subsystem=logging/logger=#{name}:read-resource'"`
  $?.exitstatus == 0
end

def create_logcategory
  handlers = '['
  unless new_resource.handlers.nil? || new_resource.handlers.empty?
    new_resource.handlers.each_with_index do |_item, index|
      handlers += '"' + new_resource.handlers[index] + '"'
      handlers += ', ' if new_resource.handlers.length - 1 != index
    end
  end
  handlers += ']'

  bash 'install_logcategory' do
    user node['wildfly']['user']
    cwd node['wildfly']['base']
    code <<-EOH
      bin/jboss-cli.sh -c command="/subsystem=logging/logger=#{new_resource.name}:add(use-parent-handlers=#{new_resource.use_parent_handlers},level=#{new_resource.level},handlers=#{handlers})"
    EOH
  end
end

def delete_logcategory
  bash 'remove_datasource' do
    user node['wildfly']['user']
    cwd node['wildfly']['base']
    code <<-EOH
      `su #{node['wildfly']['user']} -s /bin/bash -c "#{node['wildfly']['base']}/bin/jboss-cli.sh -c ' /subsystem=logging/logger=#{name}:remove'"`
    EOH
  end
end
