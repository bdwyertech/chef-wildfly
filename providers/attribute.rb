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
include Chef::Mixin::ShellOut

# Support whyrun
def whyrun_supported?
  true
end

action :set do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already set - nothing to do."
  else
    converge_by("Set #{ @new_resource }") do
      attribute_set
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::WildflyAttribute.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.parameter(@new_resource.parameter)
  @current_resource.value(@new_resource.value)
  @current_resource.restart(@new_resource.restart)
  @current_resource.exists = false
  @current_resource.path(@new_resource.path)
  if attribute_exists?
    @current_resource.exists = true
  else
    # Only notify if restart parameter is true
    if @current_resource.restart
      @new_resource.updated_by_last_action(true)
    else
      @new_resource.updated_by_last_action(false)
    end
  end
end

private

def attribute_exists?
  result = shell_out("bin/jboss-cli.sh -c '#{current_resource.path}:read-attribute(name=#{current_resource.parameter})'", user: node['wildfly']['user'], cwd: node['wildfly']['base'])
  result.stdout.include? " #{current_resource.value}"
end

def attribute_set
  result = shell_out("bin/jboss-cli.sh -c '#{current_resource.path}:write-attribute(name=#{current_resource.parameter},value=#{current_resource.value})'", user: node['wildfly']['user'], cwd: node['wildfly']['base'])
  result.exitstatus == 0
end
