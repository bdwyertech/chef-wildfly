# Encoding: UTF-8

#
# Cookbook:: wildfly
# Resource:: user
#
# Copyright:: 2019 Brian Dwyer - Intelligent Digital Services
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
resource_name :wildfly_user
provides :wildfly_user

property :username, String, name_property: true
property :password, String, sensitive: true
property :roles, Array, default: []
property :realm, String, equal_to: %w(ManagementRealm ApplicationRealm), default: 'ManagementRealm'
property :instance, String, default: 'wildfly'

action :create do
end
