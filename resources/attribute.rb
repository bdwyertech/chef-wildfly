# encoding: UTF-8
#
# LWRP that sets an attribute
#

actions :set
default_action :set

attribute :name,          :kind_of => String, :required => true, :name_attribute => true
attribute :parameter,     :kind_of => String
attribute :value,         :kind_of => String
attribute :path,          :kind_of => String
attribute :restart,       :kind_of =>  [TrueClass, FalseClass], :default => true

attr_accessor :exists
