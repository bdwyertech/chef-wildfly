# encoding: UTF-8
# rubocop:disable LineLength, SpecialGlobalVars, HashSyntax
#
# LWRP that provisions a datasource
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

actions :create, :delete
default_action :create

attribute :name,          :kind_of => String, :required => true, :name_attribute => true
attribute :jndiname,      :kind_of => String
attribute :drivername,    :kind_of => String
attribute :connectionurl, :kind_of => String

attr_accessor :exists
