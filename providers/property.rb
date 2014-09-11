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
require 'shellwords'
include Chef::Mixin::ShellOut

# Support whyrun
def whyrun_supported?
  true
end

action :set do
  if property_value_exists?
    Chef::Log.info "#{ @new_resource } already set - nothing to do."
  else
    converge_by("Set #{ @new_resource }") do
      property_set
    end
    notify?
  end
end

action :delete do
  if property_exists?
    converge_by("Delete #{ @new_resource }") do
      property_delete
    end
    notify?
  else
    Chef::Log.info "#{ @new_resource } not present - nothing to do."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::WildflyProperty.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.property(@new_resource.property)
  @current_resource.value(@new_resource.value)
  @current_resource.restart(@new_resource.restart)
end

private

def notify?
  # Only notify if restart parameter is true
  if @current_resource.restart
    @new_resource.updated_by_last_action(true)
  else
    @new_resource.updated_by_last_action(false)
  end
end

def property_value_exists?
  result = shell_out("bin/jboss-cli.sh -c '/system-property=#{current_resource.property}:read-attribute(name=value)'", user: node['wildfly']['user'], cwd: node['wildfly']['base'])
  result.stdout.include? " \"#{current_resource.value}\""
end

def property_exists?
  result = shell_out("bin/jboss-cli.sh -c '/system-property=#{current_resource.property}:read-resource'", user: node['wildfly']['user'], cwd: node['wildfly']['base'])
  result.exitstatus == 0
end

def property_set
  if property_exists?
    result = shell_out("bin/jboss-cli.sh -c '/system-property=#{current_resource.property}:write-attribute(name=value,value=#{Shellwords.escape(current_resource.value)})'", user: node['wildfly']['user'], cwd: node['wildfly']['base'])
  else
    result = shell_out("bin/jboss-cli.sh -c '/system-property=#{current_resource.property}:add(value=#{Shellwords.escape(current_resource.value)})'", user: node['wildfly']['user'], cwd: node['wildfly']['base'])
  end
  result.exitstatus == 0
end

def property_delete
  result = shell_out("bin/jboss-cli.sh -c '/system-property=#{current_resource.property}:remove()'", user: node['wildfly']['user'], cwd: node['wildfly']['base'])
  result.exitstatus == 0
end
