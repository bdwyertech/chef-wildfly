# encoding: UTF-8
# rubocop:disable LineLength, SpecialGlobalVars
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

action :install do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      deploy_install
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::WildflyDeploy.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.path(@new_resource.path)
  @current_resource.url(@new_resource.url)
  @current_resource.exists = false
  @current_resource.cli(" #{@new_resource.path}")
  @current_resource.exists = true if deploy_exists?(@current_resource.name)
  @current_resource.cli("--url=#{@new_resource.url}") if @current_resource.url != 'nourl'
end

private

def deploy_exists?(name)
  `su #{node['wildfly']['user']} -s /bin/bash -c "#{node['wildfly']['base']}/bin/jboss-cli.sh -c ' deployment-info --name=#{name}'"`
  $?.exitstatus == 0
end

def deploy_install
  bash 'deploy_install' do
    user node['wildfly']['user']
    cwd node['wildfly']['base']
    code <<-EOH
      bin/jboss-cli.sh -c "deploy #{current_resource.cli} --name=#{current_resource.name}"
    EOH
  end
end
