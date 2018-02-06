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

# => MySQL ConnectorJ
default['wildfly']['mysql'].tap do |mysql|
  mysql['enabled']  = true
  mysql['url']      = 'https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.45.tar.gz'
  mysql['checksum'] = '1d289a056c7eb8290108a8d2e3c4717193662a9171adb56cfa3b769b32de3300'

  # => MySQL ConnectorJ JDBC Module Name
  mysql['mod_name'] = 'com.mysql'
  # => MySQL ConnectorJ Module Dependencies
  mysql['mod_deps'] = ['javax.api', 'javax.transaction.api']
  mysql['mod_deps_optional'] = ['javax.servlet.api']
end
