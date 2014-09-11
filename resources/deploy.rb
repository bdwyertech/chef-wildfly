# encoding: UTF-8
# rubocop:disable LineLength, SpecialGlobalVars, HashSyntax
#
# LWRP that deploys war "name" from either path :path or url :url
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
actions :install, :remove, :enable, :disable
default_action :install

attribute :name,          :kind_of => String, :required => true, :name_attribute => true
attribute :runtime_name,  :kind_of => String, :default => 'noname'
attribute :path,          :kind_of => String, :default => 'nopath'
attribute :url,           :kind_of => String, :default => 'nourl'
attribute :cli,           :kind_of => String

attr_accessor :exists
