# Encoding: UTF-8
name             'wildfly'
maintainer       'Brian Dwyer - Intelligent Digital Services'
maintainer_email 'bdwyertech'
license          'Apache-2.0'
description      'Installs/Configures wildfly'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.0.0'
chef_version     '>= 12.19' if respond_to?(:chef_version)

supports 'centos'
supports 'ubuntu'

depends 'systemd'

gem 'net-http-digest_auth'

source_url 'https://github.com/bdwyertech/chef-wildfly' if respond_to?(:source_url)
issues_url 'https://github.com/bdwyertech/chef-wildfly/issues' if respond_to?(:issues_url)
