# encoding: UTF-8
#
# LWRP that provisions a datasource
# rubocop:disable LineLength, SpecialGlobalVars, HashSyntax
#

actions :create, :delete
default_action :create

attribute :name,          :kind_of => String, :required => true, :name_attribute => true
attribute :type,      :kind_of => String, :required => true
attribute :hostname,    :kind_of => String, :default => "localhost"
attribute :server_address,    :kind_of => String, :default => "localhost"
attribute :port,    :kind_of => String, :default => "514"
attribute :level,    :kind_of => String, :default => "ALL"
attribute :syslog_format,    :kind_of => String, :default => "RFC5424"
attribute :enabled,    :kind_of => String, :default => "true"
attribute :app_name,    :kind_of => String, :required => true

attr_accessor :exists
