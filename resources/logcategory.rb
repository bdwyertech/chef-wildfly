# encoding: UTF-8
#
# LWRP that provisions a datasource
# rubocop:disable LineLength, SpecialGlobalVars, HashSyntax
#

actions :create, :delete
default_action :create

attribute :name,          :kind_of => String, :required => true, :name_attribute => true
attribute :use_parent_handlers,      :kind_of => String
attribute :level,    :kind_of => String
attribute :handlers, :kind_of => Array

attr_accessor :exists
