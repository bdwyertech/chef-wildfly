# Encoding: UTF-8

#
# Cookbook Name:: wildfly
# Resource:: deploy_api
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
resource_name :wildfly_deploy_api

property :deploy_name,  String, name_property: true
property :runtime_name, String, name_property: true
property :parameters,   Hash, default: {}
property :checksum,     String, required: false
property :instance,     String, required: false

# => API Configuration
property :url,        String, required: false
property :user,       String, required: false
property :password,   String, required: false

#
# => Define the Default Resource Action
#
default_action :install

action :install do
  if runtime_exists?
    Chef::Log.info("Runtime: #{new_resource.runtime_name} already exists")
    if deploy_exists?
      if deploy_enabled?
        Chef::Log.info("Deployment: #{new_resource.deploy_name} already installed - nothing to do.")
      else
        converge_by("Enabling #{new_resource.deploy_name}") do
          deploy_enable
        end
      end
    else
      converge_by("Updating Runtime #{new_resource.runtime_name} to #{new_resource.deploy_name}") do
        # => Create the New Deployment
        deploy_install
        # => Disable the Existing Deployment for the Runtime
        runtime_disable
        # => Enable the New Deployment
        deploy_enable
      end
    end
  else
    converge_by("Deploying #{new_resource.deploy_name}") do
      # => Create the Deployment
      deploy_install
      # => Enable the New Deployment
      deploy_enable
    end
  end
end

action :remove do
  if deploy_exists?
    converge_by("Removing #{new_resource.deploy_name}") do
      deploy_remove
    end
  else
    Chef::Log.info("Deployment #{new_resource.deploy_name} does not exist - nothing to do.")
  end
end

action :enable do
  if deploy_exists?
    unless deploy_enabled?
      converge_by("Enabling #{new_resource.deploy_name}") do
        deploy_enable
      end
    end
  else
    Chef::Log.info("Deployment #{new_resource.deploy_name} does not exist - nothing to do.")
  end
end

action :disable do
  if deploy_exists?
    if deploy_enabled?
      converge_by("Disabling #{new_resource.deploy_name}") do
        deploy_disable
      end
    else
      Chef::Log.info("Deployment #{new_resource.deploy_name} already disabled - nothing to do.")
    end
  else
    Chef::Log.info("Deployment #{new_resource.deploy_name} does not exist - nothing to do.")
  end
end

# => Notes
# 1. Only one instance of a runtime-name can be deployed/enabled at any given time...
# 2. If the runtime does not have the proper extension, it will not deploy properly (e.g. .war,.ear)

action_class do
  def api_client
    @api_client ||= begin
      cfg = WildFly::Helper.wildfly_api_cfg(new_resource.instance)
      # => Chef::Log.warn(cfg) # DEBUG
      WildFly::ApiClient.new do |api|
        api.url      = new_resource.url      || cfg['api_url']
        api.user     = new_resource.user     || cfg['api_user']
        api.password = new_resource.password || cfg['api_pass']
      end
    end
  end

  def runtime_exists?
    resp = read_deployments.find { |d| d['runtime-name'] == new_resource.runtime_name }
    return false unless resp
    @existing_deploy = resp['name']
    resp
  end

  def deploy_exists?
    read_deployments.any? { |d| d['name'] == new_resource.deploy_name }
  end

  def deploy_enabled?
    read_deployments.find { |d| d['name'] == new_resource.deploy_name && d['enabled'] }
  end

  def deploy_enable
    api_client.do('deploy', ['deployment', new_resource.deploy_name])
  end

  def deploy_disable
    api_client.do('undeploy', ['deployment', new_resource.deploy_name])
  end

  def deploy_remove
    api_client.do('remove', ['deployment', new_resource.deploy_name])
  end

  def runtime_disable
    deploy = read_deployments.find { |d| d['runtime-name'] == new_resource.runtime_name && d['enabled'] }
    return unless deploy
    deploy = deploy['name']
    api_client.do('undeploy', ['deployment', deploy])
  end

  def runtime_remove
    deploy = read_deployments.find { |d| d['runtime-name'] == new_resource.runtime_name }
    return unless deploy
    deploy = deploy['name']
    api_client.do('remove', ['deployment', deploy])
  end

  def deploy_checksum(deployment)
    bin = Base64.decode64(deployment['content'].first['hash']['BYTES_VALUE'])
    bin.each_byte.map { |b| b.to_s(16) }.join
  end

  def deploy_install
    path = [
      'deployment',
      new_resource.deploy_name,
    ]
    deploy = {
      'content' => [new_resource.parameters],
      'runtime-name' => new_resource.runtime_name,
    }
    api_client.do('add', path, deploy)
  end

  def read_deployments
    r = api_client.do('read-resource', ['deployment', '*'])
    return [] unless r['result']
    r['result'].map { |x| x['result'] }.compact
  end

  # => Handle API Responses
  def response_handler(response)
    if response['outcome'] == 'success'
      headers = response['response-headers'] || {}
      if headers['operation-requires-reload'] == true
        Chef::Log.warn("#{new_resource}: Operation Requires WildFly Reload")
      end
    else
      wf_log(response)
    end
  end

  def wf_log(message, type = 'Error')
    msg = begin
      Chef::JSONCompat.to_json_pretty(message)
    rescue
      message
    end
    Chef::Log.warn("#{new_resource}: #{type}: " + msg)
  end
end
