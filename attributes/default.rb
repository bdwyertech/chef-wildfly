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

# => Wildfly Configuration
# => Source
default['wildfly']['version'] = '13.0.0'
default['wildfly']['url'] = 'http://download.jboss.org/wildfly/13.0.0.Final/wildfly-13.0.0.Final.tar.gz'
default['wildfly']['checksum'] = 'f74fa1882a83fc6650fb43d21ed4527eeb5478f39878f15f1f79d3dc01a997f9'

# => Interface Configuration
default['wildfly']['int']['mgmt']['bind'] = '0.0.0.0'
default['wildfly']['int']['mgmt']['http_port'] = '9990'
default['wildfly']['int']['mgmt']['https_port'] = '9993'

default['wildfly']['int']['pub']['bind'] = '0.0.0.0'
default['wildfly']['int']['pub']['http_port'] = '8080'
default['wildfly']['int']['pub']['https_port'] = '8443'

default['wildfly']['int']['wsdl']['bind'] = '0.0.0.0'
default['wildfly']['int']['ajp']['port'] = '8009'

# => Use this to offset all port bindings.  Each binding will be incremented by this value.
default['wildfly']['int']['port_binding_offset'] = '0'

# => Init Script Timeouts (Seconds)
default['wildfly']['initd']['startup_wait'] = '60'
default['wildfly']['initd']['shutdown_wait'] = '60'
