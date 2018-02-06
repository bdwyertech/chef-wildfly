# Encoding: UTF-8

#
# Cookbook Name:: wildfly
# Resource:: property
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

require 'shellwords'

# => Define the Resource Name
resource_name :wildfly_attribute

# => Define the Resource Properties
property :parameter, String, required: true, name_property: true
property :value,     String, coerce: proc { |m| enable_escape ? Shellwords.escape(m) : m }
property :path,      String
property :restart,   [FalseClass, TrueClass], default: true
property :enable_escape, [FalseClass, TrueClass], default: true
property :instance, String, required: false

#
# => Define the Default Resource Action
#
default_action :set

#
# => Set an Attribute
#
action :set do
  if attribute_value_exists?
    Chef::Log.info "#{new_resource} already set - nothing to do."
  else
    converge_by("Set #{new_resource}") do
      if attribute_exists?
        attribute_set
      else
        attribute_add
      end
    end
  end
end

action_class do
  # => Include Helper Modules
  include WildFly::Helper

  def attribute_exists?
    result = jb_cli("#{new_resource.path}:read-attribute(name=#{new_resource.parameter})", new_resource.instance)
    result.exitstatus == 0
  end

  def attribute_value_exists?
    result = jb_cli("#{new_resource.path}:read-attribute(name=#{new_resource.parameter})", new_resource.instance)
    return false if result.error?
    jb_cli_to_hash(result.stdout)['result'] == new_resource.value
  end

  def attribute_add
    result = jb_cli("#{new_resource.path}:add(#{new_resource.parameter}=#{new_resource.value})", new_resource.instance)
    result.exitstatus == 0
  end

  def attribute_set
    result = jb_cli("#{new_resource.path}:write-attribute(name=#{new_resource.parameter},value=#{new_resource.value})", new_resource.instance)
    result.exitstatus == 0
  end
end
