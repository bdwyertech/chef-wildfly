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

default['wildfly']['postgresql']['jndi']['datasources'] = [
  {
    pool_name: 'test',
    jndi_name: 'java:jboss/datasources/test',
    server: '127.0.0.1',
    port: '5432',
    db_name: 'test',
    db_user: 'test_user',
    db_pass: 'test_pass',
    pool_min: '5',
    pool_max: '20',
  },
  {
    pool_name: 'test2',
    jndi_name: 'java:jboss/datasources/test2',
    server: '127.0.0.1',
    port: '5432',
    db_name: 'test2',
    db_user: 'test_user',
    db_pass: 'test_pass',
    pool_min: '5',
    pool_max: '20',
  },
]
