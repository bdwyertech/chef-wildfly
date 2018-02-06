# Encoding: UTF-8

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

# => Wildfly User Configuration

# => Access Control Provider (simple, or rbac)
default['wildfly']['acp'] = 'simple'

# => By default, Wildfly expexts this password hash format:
# => # => username=HEX( MD5( username ':' realm ':' password))

# => Default user - wildfly - wildfly
default['wildfly']['users']['mgmt'].tap do |user|
  user['wildfly'] = '2c6368f4996288fcc621c5355d3e39b7'
end

# Add application users to the hash 'app'  eg.
#
default['wildfly']['users']['app'].tap do |user|
  user['wildfly'] = '2c6368f4996288fcc621c5355d3e39b7'
end

# Add application roles eg.
#
default['wildfly']['roles']['app'].tap do |role|
  role['wildfly'] = 'role1,role2'
end
