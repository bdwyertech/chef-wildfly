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

# => MySQL Database Configuration
# => MySQL ConnectorJ
default['wildfly']['mysql']['enabled'] = true
default['wildfly']['mysql']['url'] = 'http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.39.tar.gz'
default['wildfly']['mysql']['checksum'] = 'fa1bdc9ee5323642c5a533fa73fbcf537b26a979e5981c486c24256c433c7718'

# => MySQL ConnectorJ JDBC Module Name
default['wildfly']['mysql']['mod_name'] = 'com.mysql'
# => MySQL ConnectorJ Module Dependencies
default['wildfly']['mysql']['mod_deps'] = ['javax.api', 'javax.transaction.api']
