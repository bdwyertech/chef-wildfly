# Encoding: UTF-8

# Cookbook Name:: wildfly
# Recipe:: install
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

# => Shorten Hashes
wildfly = node['wildfly']

service 'wildfly' do
  action :nothing
end

wildfly 'wildfly' do
  launch_arguments [
    # => '-Dorg.jboss.as.logging.per-deployment=false'
  ]
  server_properties [
    "jboss.socket.binding.port-offset=#{wildfly['int']['port_binding_offset']}",
    "jboss.bind.address.management=#{wildfly['int']['mgmt']['bind']}",
    "jboss.management.http.port=#{wildfly['int']['mgmt']['http_port']}",
    "jboss.management.https.port=#{wildfly['int']['mgmt']['https_port']}",
    "jboss.bind.address=#{wildfly['int']['pub']['bind']}",
    "jboss.http.port=#{wildfly['int']['pub']['http_port']}",
    "jboss.https.port=#{wildfly['int']['pub']['https_port']}",
    "jboss.ajp.port=#{wildfly['int']['ajp']['port']}",
  ]
  action :install
end
