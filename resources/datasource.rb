# encoding: UTF-8
#
# LWRP that provisions a datasource
# rubocop:disable LineLength, SpecialGlobalVars, HashSyntax
#

actions :create, :delete
default_action :create

attribute :name,          :kind_of => String, :required => true, :name_attribute => true
attribute :jndiname,      :kind_of => String
attribute :drivername,    :kind_of => String
attribute :connectionurl, :kind_of => String

attr_accessor :exists
