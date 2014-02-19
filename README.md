# wildfly cookbook
Cookbook to deploy Wildfly Java Application Server

# Requirements
Chef Client 11+
Java Opscode Community Cookbook

# Platform
- CentOS, Red Hat, Fedora
- EC2 Amazon Linux AMI

Tested on:
- CentOS 6.5

# Usage
You can add users in the proper format to `attributes\users.rb`

You can customize the Java version, and the Connector/J if you'd like.

# Attributes
* `node['wildfly']['base']` - Base directory to run Wildfly from

* `node['wildfly']['version']` - Specify the version of Wildfly
* `node['wildfly']['url']` - URL to Wildfly tarball
* `node['wildfly']['checksum']` - SHA256 hash of said tarball

* `node['wildfly']['user']` - User to run Wildfly as.
* `node['wildfly']['group']` - Group which owns Wildfly directories
* `node['wildfly']['server']` - Name of service and init.d script for daemonizing

* `node['wildfly']['mysql']['enabled']` - Boolean indicating Connector/J support

* `node['wildfly']['int'][*]` - Various hashes for setting interface & port bindings

* `node['wildfly']['smtp']['host']` - SMTP Destination host
* `node['wildfly']['smtp']['port']` - SMTP Destination port


# Recipes
::default - Installs Java & Wildfly.  Also installs Connector/J if you've got it enabled.
::install - Installs Wildfly.
::mysql_connector - Installs Connector/J into appropriate Wildfly directory.

# Author

Author:: Brian Dwyer - Intelligent Digital Services
