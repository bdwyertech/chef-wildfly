# Encoding: UTF-8

#
# Cookbook Name:: wildfly
# Resource:: deploy
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
resource_name :wildfly_deploy

property :deploy_name,  String, name_property: true
property :runtime_name, String, name_property: true
property :path,         String, required: false
property :url,          String, required: false
property :cli,          String, required: false
property :instance,     String, required: false

#
# => Define the Default Resource Action
#
default_action :install

action :install do
  if runtime_exists?
    Chef::Log.info("#{new_resource.runtime_name} already exists")
    if deploy_exists?
      Chef::Log.info("#{new_resource.deploy_name} already enabled - nothing to do.")
    else
      converge_by("#{new_resource.deploy_name} is not the active resource.") do
        deploy_remove(new_resource.runtime_name, false)
        read_deployment_details(true)
        deploy_install(deploy_cli, new_resource.deploy_name, new_resource.runtime_name)
      end
    end
  else
    converge_by("install #{new_resource.deploy_name}") do
      deploy_install(deploy_cli, new_resource.deploy_name, new_resource.runtime_name)
    end
  end
end

action :remove do
  if runtime_exists?
    converge_by("remove #{current_resource.runtime_name}") do
      deploy_remove(new_resource.runtime_name, false)
    end
  else
    Chef::Log.info("#{new_resource.runtime_name} does not exist - nothing to do.")
  end
end

action :enable do
  if runtime_exists?
    Chef::Log.info("#{new_resource.runtime_name} already exists")
    if deploy_exists?
      if deploy_enabled?(new_resource.deploy_name)
        Chef::Log.info("#{new_resource.deploy_name} resource is already enabled.")
      else
        converge_by("#{new_resource.deploy_name} activating previously loaded resource.") do
          deploy_install('', new_resource.deploy_name, new_resource.runtime_name)
        end
      end
    else
      Chef::Log.info("#{new_resource.deploy_name} resource does not exist yet, cannot enable.")
    end
  else
    Chef::Log.info("#{new_resource.runtime_name} resource does not exist yet, cannot enable.")
  end
end

action :disable do
  if runtime_exists?
    converge_by("disable #{new_resource.runtime_name}") do
      deploy_remove(new_resource.runtime_name, true)
    end
  else
    Chef::Log.info "#{new_resource.runtime_name} does not exist - nothing to do."
  end
end

action_class do
  # => Include Helper Modules
  include WildFly::Helper

  def runtime_exists?
    read_deployment_details.key?(new_resource.runtime_name)
  end

  def deploy_exists?
    read_deployment_details[new_resource.runtime_name].any? { |h| h[new_resource.deploy_name] }
  end

  def deploy_enabled?(deploy_name)
    read_deployment_details[new_resource.runtime_name].any? { |h| h[deploy_name]['enabled'] }
  end

  def deploy_cli
    if new_resource.cli
      new_resource.cli
    elsif new_resource.path
      new_resource.path
    elsif new_resource.url
      "--url=#{new_resource.url}"
    end
  end

  def deploy_install(source, deploy_name, runtime_name)
    Chef::Log.info("Deploying #{deploy_name}")
    converge_by((source == '' ? 'Enabling' : 'Deploying') + " #{detailed_name(runtime_name, deploy_name)}") do
      result = jb_cli("deploy #{source} --name=#{deploy_name} --runtime-name=#{runtime_name}", new_resource.instance)
      result.error! if result.exitstatus != 0
    end
    true
  end

  def deploy_remove(runtime_name, keep_content = false)
    deployments = read_deployment_details
    deployments[runtime_name].each do |deployed|
      converge_by((keep_content ? 'Disabling' : 'Removing') + " #{detailed_name(runtime_name, deployed.keys.first)}") do
        Chef::Log.info("Undeploying #{detailed_name(runtime_name, deployed.keys.first)}")
        result = jb_cli("undeploy #{deployed.keys.first} #{keep_content ? '--keep-content' : ''}", new_resource.instance)
        result.error! if result.exitstatus != 0
      end
    end
    true
  end

  def read_deployment_details(refresh = false)
    if !@deployment_details || refresh
      Chef::Log.info('Getting list of deployed applications')
      data = jb_cli('deployment-info', new_resource.instance)
      @deployment_details = format_output(data.stdout)
    end
    @deployment_details
  end

  def detailed_name(runtime_name, deploy_name)
    runtime_name == deploy_name ? runtime_name : "#{runtime_name} (#{deploy_name})"
  end

  def format_output(data)
    result = {}
    data.split(/\n/).each do |item|
      output = item.split(/\s+/)
      if result.key?(output[1])
        result[output[1]] << { output[0] => { persistent: output[2], enabled: output[3], status: output[4] } }
      else
        result = { output[1] => [output[0] => { persistent: output[2], enabled: output[3], status: output[4] }] }.merge(result)
      end
    end
    result
  end
end
