# Encoding: UTF-8

#
# Cookbook Name:: wildfly
# Resource:: resource
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
resource_name :wildfly_resource

# => Define the Resource Properties
property :path,       [Array, String], default: [], coerce: proc { |x| x.is_a?(String) ? WildFly::ApiClient.address(x) : x }
property :parameters, Hash, default: {}
property :operation_headers, Hash, default: {}
property :instance,   String, required: false
property :reload,     [FalseClass, TrueClass], default: false

# => Maybe we want these for operating remotely?
property :url,        String, required: false
property :user,       String, required: false
property :password,   String, required: false

def initialize(*args)
  super
  # => Ignore Failure unless set otherwise
  @ignore_failure = true
end

#
# => Define the Default Resource Action
#
default_action :create

#
# => Define the Create Action
#
action :create do
  #
  # => Create/Update a WildFly Resource
  #

  # => Call the API, see if it exists
  resp = api_client.do('read-resource', new_resource.path)
  if resp['outcome'] == 'success'
    # => Compare parameters against returned values
    # => If any values differ, attempt to set them.  Ignore keys that don't exist in the WildFly response
    # => :write-attribute(name=k,value=v)
    to_update = new_resource.parameters.select do |k, v|
      # => Ensure the Key Exists
      unless resp['result'].keys.include?(k.to_s)
        Chef::Log.warn("#{new_resource}: Unknown Key: #{k}")
        next
      end
      # => Need to compare as strings
      resp['result'][k.to_s].to_s != v.to_s
    end
    # => Set Differing Parameters
    to_update.each do |k, v|
      Chef::Log.warn("#{new_resource}: Setting #{k} = #{v}")
      param = { 'name' => k, 'value' => v }
      converge_by("#{new_resource}: Updating Parameter: #{k} = #{v}") do
        resp = api_client.do('write-attribute', new_resource.path, param, new_resource.operation_headers)
        response_handler(resp)
      end
    end
  elsif resp['outcome'] == 'failed'
    # => Add the new resource with all its parameters
    # => :add(k1=v1, k2=v2, k3=v3)
    converge_by("#{new_resource}: Creating Resource") do
      resp = api_client.do('add', new_resource.path, new_resource.parameters, new_resource.operation_headers)
      response_handler(resp)
    end
  else
    # => Unknown API Response, 'outcome' should always be returned
    Chef::Log.warn('WildFly - Unknown API Response: ' + resp.inspect)
  end
end

action :set do
  # => Alias Set to Create
  new_resource.run_action(:create)
end

action :create_if_missing do
  #
  # => Create a WildFly Resource unless already present
  #

  # => Call the API, see if it exists
  resp = api_client.do('read-resource', new_resource.path)
  # => Response should be 'failed' if it does not exist
  case resp['outcome']
  when 'failed'
    new_resource.run_action(:set)
  when 'success'
    # => Already Exists
    return
  else
    Chef::Log.warn('WildFly - Unknown API Response: ' + resp.inspect)
  end
end

action :unset do
  # => Call the API, see if it exists
  resp = api_client.do('read-resource', new_resource.path)
  if resp['outcome'] == 'success'
    # => We can set the specific parameter to the string undefined
  end
end

action :delete do
  #
  # => Delete a WildFly Resource
  #

  # => Call the API, see if it exists
  resp = api_client.do('read-resource', new_resource.path)
  if resp['outcome'] == 'success'
    # => Delete the Resource
    converge_by("#{new_resource}: Deleting Resource") do
      resp = api_client.do('remove', new_resource.path, {}, new_resource.operation_headers)
      response_handler(resp)
    end
  end
end

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
