# Encoding: UTF-8

#
# Cookbook Name:: wildfly
# Resource:: logcategory
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
resource_name :wildfly_logcategory

property :logger, String, name_property: true
property :use_parent_handlers, String
property :level,    String
property :handlers, Array
property :instance, String, required: false

#
# => Define the Default Resource Action
#
default_action :create

#
# => Create a Log Category
#
action :create do
  if logcategory_exists?
    Chef::Log.info "#{new_resource} already exists - nothing to do."
  else
    converge_by("Create #{new_resource}") do
      create_logcategory
    end
  end
end

#
# => Delete a Log Category
#
action :delete do
  if logcategory_exists?
    converge_by("Delete #{new_resource}") do
      delete_logcategory
    end
  else
    Chef::Log.info "#{new_resource} doesn't exist - can't delete."
  end
end

action_class do
  # => Include Helper Modules
  include WildFly::Helper

  def logcategory_exists?
    result = jb_cli("/subsystem=logging/logger=#{new_resource.logger}:read-resource", new_resource.instance)
    result.exitstatus == 0
  end

  def create_logcategory
    handlers = '['
    unless new_resource.handlers.nil? || new_resource.handlers.empty?
      new_resource.handlers.each_with_index do |_item, index|
        handlers += '"' + new_resource.handlers[index] + '"'
        handlers += ', ' if new_resource.handlers.length - 1 != index
      end
    end
    handlers += ']'

    params = [
      "use-parent-handlers=#{new_resource.use_parent_handlers}",
      "level=#{new_resource.level}",
      "handlers=#{handlers}",
    ].join(',')

    jb_cli("/subsystem=logging/logger=#{new_resource.logger}:add(#{params})", new_resource.instance)
  end

  def delete_logcategory
    jb_cli("/subsystem=logging/logger=#{new_resource.logger}:remove", new_resource.instance)
  end
end
