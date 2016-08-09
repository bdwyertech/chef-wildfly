# encoding: UTF-8
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

# => Wildfly User Configuration

# => Access Control Provider (simple, or rbac)
default['wildfly']['acp'] = 'simple'

# => By default, Wildfly expexts this password hash format:
# => # => username=HEX( MD5( username ':' realm ':' password))

# => Default user - wildfly - wildfly
default['wildfly']['users']['mgmt'] = [
  { id: 'wildfly', passhash: '2c6368f4996288fcc621c5355d3e39b7' }
]

# => Add application users to the hash 'app'  eg.
default['wildfly']['users']['app'] = [
  { id: 'wildfly', passhash: '8b1ef623011c8dd9760f89e1847fa135' }
]

# => Add application roles eg.
default['wildfly']['roles']['app'] = [
  { id: 'wildfly', roles: 'role1,role2' }
]

# => Create symbolic links for user files
default['wildfly']['configuration']['domain_path'] = "#{wildfly['base']}/domain/configuration/"
default['wildfly']['configuration']['standalone_path'] = "#{wildfly['base']}/standalone/configuration/"
default['wildfly']['configuration']['filenames'] = [
   'mgmt-users.properties',
   'application-roles.properties',
   'application-users.properties'
]