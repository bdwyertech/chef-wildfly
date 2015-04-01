# encoding: UTF-8
# rubocop:disable SingleSpaceBeforeFirstArg
name             'wildfly'
maintainer       'Brian Dwyer - Intelligent Digital Services'
maintainer_email 'bdwyertech'
license          'Apache License, Version 2.0'
description      'Installs/Configures wildfly'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.19'

supports 'centos'

depends 'apt'
depends 'yum'
depends 'java', '~> 1.22'
