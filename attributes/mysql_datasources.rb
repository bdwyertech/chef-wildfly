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

# => MySQL Datasource Definitions
# => Stored as an array of hashes

# => Pool values are # of connections.
# => Connections are kept open until they time out.
#
# => Timeout is in minutes.
# => *** Check the timeout values on the MySQL DB ***
# => ***   Make sure the timeout here is lower!   ***

default['wildfly']['mysql']['jndi']['datasources'] = [
  {
    jndi_name: 'java:jboss/datasources/test',
    server: '127.0.0.1',
    port: '3306',
    db_name: 'test',
    db_user: 'test_user',
    db_pass: 'test_pass',
    pool_min: '5',
    pool_max: '20',
    timeout: '5',
  },
  {
    jndi_name: 'java:jboss/datasources/test2',
    server: '127.0.0.1',
    port: '3306',
    db_name: 'test2',
    db_user: 'test_user',
    db_pass: 'test_pass',
    pool_min: '5',
    pool_max: '20',
    timeout: '5',
  },
]
