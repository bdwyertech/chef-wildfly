# encoding: UTF-8
#
# LWRP that sets a system property
#
# rubocop:disable LineLength, SpecialGlobalVars, HashSyntax

actions :set, :delete
default_action :set

attribute :name,          :kind_of => String, :required => true, :name_attribute => true
attribute :property,      :kind_of => String, :required => true
attribute :value,         :kind_of => String
attribute :restart,       :kind_of => [TrueClass, FalseClass], :default => true

attr_accessor :exists