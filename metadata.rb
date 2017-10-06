# encoding: UTF-8
name             'wildfly'
maintainer       'Brian Dwyer - Intelligent Digital Services'
maintainer_email 'bdwyertech'
license          'Apache License, Version 2.0'
description      'Installs/Configures wildfly'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.4.2'

supports 'centos'



source_url 'https://github.com/bdwyertech/chef-wildfly' if respond_to?(:source_url)
issues_url 'https://github.com/bdwyertech/chef-wildfly/issues' if respond_to?(:issues_url)
