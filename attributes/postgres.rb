# encoding: UTF-8
# rubocop:disable LineLength
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

# => PostgreSQL Database Configuration
# => PostgreSQL driver
default['wildfly']['postgresql']['enabled'] = true
default['wildfly']['postgresql']['url'] = 'http://central.maven.org/maven2/org/postgresql/postgresql/9.3-1102-jdbc41/postgresql-9.3-1102-jdbc41.jar'
default['wildfly']['postgresql']['checksum'] = 'c4530047d03bac8295a9c19fbd7b893b5981edbcd8e52e1597fa2385deec272f'

# => PostgreSQL driver JDBC Module Name
default['wildfly']['postgresql']['mod_name'] = 'org.postgresql'
# => PostgreSQL driver Module Dependencies
default['wildfly']['postgresql']['mod_deps'] = ['javax.api', 'javax.transaction.api']
