# encoding: UTF-8
#
# LWRP that deploys war "name"
# From either path :path or url :url
#
actions :install
default_action :install

attribute :name,          :kind_of => String, :required => true, :name_attribute => true
attribute :path,          :kind_of => String, :default => 'nopath'
attribute :url,           :kind_of => String, :default => 'nourl'
attribute :cli,           :kind_of => String

attr_accessor :exists
