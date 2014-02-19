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
include_recipe 'wildfly::install'
include_recipe 'wildfly::mysql_connector'
