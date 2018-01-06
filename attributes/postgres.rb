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

# => PostgreSQL Driver
default['wildfly']['postgresql'].tap do |postgresql|
  postgresql['enabled'] = true
  postgresql['url'] = 'https://jdbc.postgresql.org/download/postgresql-42.1.4.jar'
  postgresql['checksum'] = '4523ed32e9245e762e1df9f0942a147bece06561770a9195db093d9802297735'

  # => PostgreSQL driver JDBC Module Name
  postgresql['mod_name'] = 'org.postgresql'
  # => PostgreSQL driver Module Dependencies
  postgresql['mod_deps'] = ['javax.api', 'javax.transaction.api']
  postgresql['mod_deps_optional'] = ['javax.servlet.api']
end
