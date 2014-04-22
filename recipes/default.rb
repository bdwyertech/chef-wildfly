# encoding: UTF-8
#
# Cookbook Name:: wildfly
# Recipe:: default
#
# Copyright (C) 2014 Brian Dwyer - Intelligent Digital Services
# 
# All rights reserved - Do Not Redistribute
#

include_recipe 'java'
include_recipe 'sbp_wildfly::install'
include_recipe 'sbp_wildfly::mysql_connector' if node['wildfly']['mysql']['enabled']
