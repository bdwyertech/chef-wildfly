# encoding: UTF-8
name             'wildfly'
maintainer       'Lydia Joslin - Ultralinq Healthcare'
maintainer_email 'lejoslin@ncsu.edu'
license          'Apache License, Version 2.0'
description      'Installs/Configures wildfly'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.2'

supports 'centos', '>= 6.0'

depends 'apt'
depends 'yum'
depends 'java', '~> 1.22'

source_url 'https://github.com/estelora/chef-wildfly' if respond_to?(:source_url)
issues_url 'https://github.com/estelora/chef-wildfly/issues' if respond_to?(:issues_url)
