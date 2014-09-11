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
include Chef::Mixin::ShellOut

# Support whyrun
def whyrun_supported?
  true
end

action :install do
  if runtime_exists?
    Chef::Log.info "#{ @new_resource.runtime_name } already exists"
    if deploy_exists?
      Chef::Log.info "#{ @new_resource.name } already enabled - nothing to do."
    else
      Chef::Log.info "#{ @new_resource.name } is not the active resource."
      deploy_remove(@current_resource.runtime_name, false)
      read_deployment_details(true)
      deploy_install(@current_resource.cli, @current_resource.name, @current_resource.runtime_name)
    end
  else
    deploy_install(@current_resource.cli, @current_resource.name, @current_resource.runtime_name)
  end
end

action :remove do
  if runtime_exists?
    deploy_remove(@current_resource.runtime_name, false)
  else
    Chef::Log.info "#{ @new_resource.runtime_name } does not exist - nothing to do."
  end
end

action :enable do
  if runtime_exists?
    Chef::Log.info "#{ @new_resource.runtime_name } already exists"
    if deploy_exists?
      if deploy_enabled?(@current_resource.name)
        Chef::Log.info "#{ @new_resource.name } resource is already enabled."
      else
        Chef::Log.info "#{ @new_resource.name } activating previously loaded resource."
        deploy_install('', @current_resource.name, @current_resource.runtime_name)
      end
    else
      Chef::Log.info "#{ @new_resource.name } resource does not exist yet, cannot enable."
    end
  else
    Chef::Log.info "#{ @new_resource.runtime_name } resource does not exist yet, cannot enable."
  end
end

action :disable do
  if runtime_exists?
    deploy_remove(@current_resource.runtime_name, true)
  else
    Chef::Log.info "#{ @new_resource.runtime_name } does not exist - nothing to do."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::WildflyDeploy.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.runtime_name(@new_resource.runtime_name == 'noname' ? @new_resource.name : @new_resource.runtime_name)
  @current_resource.path(@new_resource.path)
  @current_resource.url(@new_resource.url)
  @current_resource.exists = false
  @current_resource.cli(" #{@new_resource.path}")
  @current_resource.exists = true if runtime_exists?
  @current_resource.cli("--url=#{@new_resource.url}") if @current_resource.url != 'nourl'
end

private

def runtime_exists?
  read_deployment_details.key?(@current_resource.runtime_name)
end

def deploy_exists?
  read_deployment_details[@current_resource.runtime_name].any? { |h| h[@current_resource.name] }
end

def deploy_enabled?(name)
  read_deployment_details[@current_resource.runtime_name].any? { |h| h[name]['enabled'] }
end

def deploy_install(source, name, runtime_name)
  Chef::Log.info "Deploying #{name}"
  converge_by((source == '' ? 'Enabling' : 'Deploying') + " #{ detailed_name(runtime_name, name) }") do
    result = shell_out("bin/jboss-cli.sh -c ' deploy #{source} --name=#{name} --runtime-name=#{runtime_name}'", user: node['wildfly']['user'], cwd: node['wildfly']['base'])
    result.error! if result.exitstatus != 0
  end
  true
end

def deploy_remove(runtime_name, keep_content = false)
  deployments = read_deployment_details
  deployments[runtime_name].each do | deployed |
    converge_by((keep_content ? 'Disabling' : 'Removing') + " #{ detailed_name(runtime_name, deployed.keys.first) }") do
      Chef::Log.info 'Undeploying #{detailed_name(runtime_name, deployed.keys.first)}'
      result = shell_out("bin/jboss-cli.sh -c ' undeploy #{deployed.keys.first} #{keep_content ? '--keep-content' : ''}'", user: node['wildfly']['user'], cwd: node['wildfly']['base'])
      result.error! if result.exitstatus != 0
    end
  end
  true
end

def read_deployment_details(refresh = false)
  if !@deployment_details || refresh
    Chef::Log.info 'Getting list of deployed applications'
    data = shell_out("bin/jboss-cli.sh -c ' deployment-info '", user: node['wildfly']['user'], cwd: node['wildfly']['base'])
    @deployment_details = format_output(data.stdout)
  end
  @deployment_details
end

def detailed_name(runtime_name, name)
  runtime_name == name ? runtime_name : "#{runtime_name} (#{name})"
end

def format_output(data)
  result = {}
  data.split(/\n/).each do | item |
    output = item.split(/\s+/)
    if result.key?(output[1])
      result[output[1]] << { output[0] => { persistent: output[2], enabled: output[3], status: output[4] } }
    else
      result = { output[1] => [output[0] => { persistent: output[2], enabled: output[3], status: output[4] }] }.merge(result)
    end
  end
  result
end
