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

# => Define the Resource Name
resource_name :wildfly_property

# => Define the Resource Properties
property :property, String, required: true, name_property: true
property :value, String
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
  if property_value_exists?
    Chef::Log.info "#{new_resource} already set - nothing to do."
  else
    converge_by("Set #{new_resource}") do
      property_set
    end
  end
end

#
# => Delete an Attribute
#
action :delete do
  if property_exists?
    converge_by("Delete #{new_resource}") do
      property_delete
    end
  else
    Chef::Log.info "#{new_resource} not present - nothing to do."
  end
end

action_class do
  def jb_cli(cmd)
    WildFly::Helper.jb_cli(cmd, new_resource.instance)
  end

  def property_value_exists?
    result = jb_cli("/system-property=#{new_resource.property}:read-attribute(name=value)")
    return false if result.error?
    convert_to_hash(result.stdout)['result'] == new_resource.value
  end

  def property_exists?
    result = jb_cli("/system-property=#{new_resource.property}:read-resource")
    result.exitstatus == 0
  end

  def property_set
    val = if new_resource.enable_escape
            Shellwords.escape(new_resource.value)
          else
            value
          end
    if property_exists? # rubocop: disable Style/ConditionalAssignment
      result = jb_cli("/system-property=#{new_resource.property}:write-attribute(name=value,value=\"#{val}\")")
    else
      result = jb_cli("/system-property=#{new_resource.property}:add(value=\"#{val}\")")
    end
    result.exitstatus == 0
  end

  def property_delete
    result = jb_cli("/system-property=#{new_resource.property}:remove()")
    result.exitstatus == 0
  end

  def convert_to_hash(txt)
    # convert_to_hash(result)['result']['value']
    # Transform object string symbols to quoted strings
    txt.gsub!(/([{,]\s*):([^>\s]+)\s*=>/, '\1"\2"=>')

    # Transform object string numbers to quoted strings
    txt.gsub!(/([{,]\s*)([0-9]+\.?[0-9]*)\s*=>/, '\1"\2"=>')

    # Transform object value symbols to quotes strings
    txt.gsub!(/([{,]\s*)(".+?"|[0-9]+\.?[0-9]*)\s*=>\s*:([^,}\s]+\s*)/, '\1\2=>"\3"')

    # Transform array value symbols to quotes strings
    txt.gsub!(/([\[,]\s*):([^,\]\s]+)/, '\1"\2"')

    # Transform object string object value delimiter to colon delimiter
    txt.gsub!(/([{,]\s*)(".+?"|[0-9]+\.?[0-9]*)\s*=>/, '\1\2:')

    JSON.parse(txt) rescue {} # rubocop: disable RescueModifier
  end
end
