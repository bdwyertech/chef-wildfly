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
  if deploy_exists?(@current_resource.runtime_name)
    Chef::Log.info "#{ @new_resource.runtime_name } already exists"
    if deploy_name_exists?(@current_resource.runtime_name, @current_resource.name)
      Chef::Log.info "#{ @new_resource.name } already enabled - nothing to do."
    else
      Chef::Log.info "#{ @new_resource.name } is not the active resource."
      deploy_remove(@current_resource.runtime_name)
      deploy_install(@current_resource.name, @current_resource.runtime_name)
    end
  else
    deploy_install(@current_resource.name, @current_resource.runtime_name)
  end
end

action :remove do
  if deploy_exists?(@current_resource.runtime_name)
    deploy_remove(@current_resource.runtime_name)
  else
    Chef::Log.info "#{ @new_resource.runtime_name } does not exist - nothing to do."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::WildflyDeploy.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.runtime_name( @new_resource.runtime_name == 'noname' ? @new_resource.name : @new_resource.runtime_name )
  @current_resource.path(@new_resource.path)
  @current_resource.url(@new_resource.url)
  @current_resource.exists = false
  @current_resource.cli(" #{@new_resource.path}")
  @current_resource.exists = true if deploy_exists?(@current_resource.name)
  @current_resource.cli("--url=#{@new_resource.url}") if @current_resource.url != 'nourl'
end

private

def deploy_exists?(runtime_name)
  return read_deployment_details.has_key?(runtime_name)
end

def deploy_name_exists?(runtime_name, name)
  return read_deployment_details[runtime_name].any? { |h| h[name] }
end

def deploy_install(name, runtime_name)
  Chef::Log.info "Deploying #{name}"
  converge_by("Deploying #{ detailed_name(runtime_name,name) }") do
    result = shell_out("bin/jboss-cli.sh -c ' deploy #{current_resource.cli} --name=#{name} --runtime-name=#{runtime_name}'", :user => node['wildfly']['user'], :cwd => node['wildfly']['base'])
    result.error! if result.exitstatus != 0
  end
  return true
end

def deploy_remove(runtime_name)
  deployments = read_deployment_details
  deployments[runtime_name].each do | deployed |
    converge_by("Removing #{ detailed_name(runtime_name, deployed.keys.first) }") do
      Chef::Log.info "Undeploying #{detailed_name(runtime_name, deployed.keys.first)}"
        Chef::Log.info "Undeploying #{deployed.keys.first} with runtime name #{runtime_name}"
        result = shell_out("bin/jboss-cli.sh -c ' undeploy #{deployed.keys.first}'", :user => node['wildfly']['user'], :cwd => node['wildfly']['base'])
        result.error! if result.exitstatus != 0
    end
  end
  return true
end

def read_deployment_details
  Chef::Log.info "Getting list of deployed applications"
  data = shell_out("bin/jboss-cli.sh -c ' deployment-info '", :user => node['wildfly']['user'], :cwd => node['wildfly']['base'])
  return format_output(data.stdout)
end

def detailed_name(runtime_name,name)
  return runtime_name==name ? "#{runtime_name}" : "#{runtime_name} (#{name})"
end

def format_output(data)
  result = {}
  data.split(/\n/).each do | item |
    output = item.split(/\s+/)
    if result.has_key?(output[1])
      result[output[1]] << { output[0] => { :persistent => output[2], :enabled => output[3], :status => output[4] } }
    else
      result = { output[1] => [ output[0] => { :persistent => output[2], :enabled => output[3], :status => output[4] } ] }.merge(result)
    end
  end
  return result
end
