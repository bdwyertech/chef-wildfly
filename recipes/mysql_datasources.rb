# Encoding: UTF-8

# Cookbook Name:: wildfly
# Recipe:: mysql_datasources
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

#
# => Check this out for defining datasources...
# => http://www.ironjacamar.org/doc/schema/datasources_1_2.xsd
#

# => Shorten Hashes
wildfly = node['wildfly']
mysql = node['wildfly']['mysql']

mysql['jndi']['datasources'].each do |source|
  # => Configure MySQL Datasource
  template ::File.join(wildfly['base'], 'standalone', 'deployments', "#{::File.basename(source['jndi_name'])}-ds.xml") do
    source 'mysql-ds.xml.erb'
    user wildfly['user']
    group wildfly['group']
    mode '0600'
    variables(
      jndi_name: source['jndi_name'],
      mysql_server: source['server'],
      mysql_port: source['port'],
      mysql_db_name: source['db_name'],
      mysql_user: source['db_user'],
      mysql_pass: source['db_pass'],
      mysql_pool_min: '5',
      mysql_pool_max: '20',
      mysql_timeout: '5'
    )
    action :create
  end
end
