# Wildfly Cookbook
Cookbook to deploy the WildFly Java Application Server

[![Cookbook](http://img.shields.io/cookbook/v/wildfly.svg)](https://github.com/bdwyertech/chef-wildfly)
[![Build Status](https://travis-ci.org/bdwyertech/chef-wildfly.svg)](https://travis-ci.org/bdwyertech/chef-wildfly)
[![Gitter chat](https://img.shields.io/badge/Gitter-bdwyertech%2Fwildfly-brightgreen.svg)](https://gitter.im/bdwyertech/chef-wildfly)

Provides resources for installing/configuring WildFly and managing WildFly service instances for use in wrapper cookbooks. Installs WildFly from tarball and installs the appropriate configuration for your platform's init system.



## Requirements

### Platforms
- RHEL and derivatives
- Ubuntu

### Chef
- Chef 12.11+

## Usage

This cookbook has recently been rewritten to be resource-driven.  It was a large undertaking and breaks old behavior, hence the major version bump.  The API-driven configuration and deployment resources are much faster to converge.

The old recipes were kept around for similar, legacy behavior, but using the resources directly in your wrapper cookbook will yield more flexibility.

Example wrapper cookbook scenarios are available in the test cookbook, under `test/fixtures/cookbooks/test`


# Attributes
* `node['wildfly']['install_java']` - Install Java using Java Cookbook.  Default `true`
* `node['wildfly']['base']` - Base directory to run Wildfly from
* `node['wildfly']['version']` - Specify the version of Wildfly
* `node['wildfly']['url']` - URL to Wildfly tarball
* `node['wildfly']['checksum']` - SHA256 hash of said tarball
* `node['wildfly']['user']` - User to run WildFly as. DO NOT MODIFY AFTER INSTALLATION!!!
* `node['wildfly']['group']` - Group which owns WildFly directories
* `node['wildfly']['service']` - Name of service for daemonizing


# Recipes
* `::default` - Installs Java, WildFly and any enabled connectors.
* `::install` - Installs Wildfly using the wildfly resource
* `::mysql_connector` - Installs MySQL Connector/J
* `::postgres_connector` - Installs PostgreSQL Java connector

# Resource Providers
### WildFly
* Installs and configures WildFly.

```ruby
wildfly_wildfly 'wildfly' do
  mode 'standalone' # => WildFly Mode
  config 'standalone-full.xml' # => The WildFly Configuration File
  base_dir '/opt/wildfly' # => Directory to install WildFly to
  service_user 'wildfly'
  service_group 'wildfly'
  provision_user true # => Whether to create the WildFly service user/group
  create_mgmt_user true # => Provision a random, secure user for API interactions
  url 'http://.../wildfly.tar.gz' # URL to WildFly tarball to download
  checksum 'SHA256_CHECKSUM' # WildFly Tarball Checksum
  version '1.2.3' # Version of WildFly (Should correspond to URL)
end
```

##### Accessor Properties
* `bind_management_http` - the HTTP port for the Management Interface & API

### Resource
* Flexible resource which allows provisioning of attributes and their parameters via the WildFly Management API.  This should be used over other resources as it affords more flexibility.

```ruby
wildfly_resource 'Syslog Handler' do
  path ['subsystem', 'logging', 'syslog-handler', 'SYSLOG']
  parameters 'app-name' => 'TEST',
             'enabled'  => true,
             'hostname' => 'localhost',
             'level'    => 'ALL',
             'port'     => 514,
             'server-address' => 'test.syslog.local',
             'syslog-format'  => 'RFC5424'
  action :create
end
```

### Deploy API
* Resource to deploy applications via the API

```ruby
# => URL-Based Deployment
wildfly_deploy_api 'Sample' do
  deploy_name 'sample-v1'
  runtime_name 'sample.war'
  parameters 'url' => 'https://github.com/apcera/sample-apps/raw/master/example-java-war/sample.war'
end
```

```ruby
# => File-Based Deployment
myapp = remote_file 'helloworld' do
  source 'https://github.com/efsavage/hello-world-war/raw/master/dist/hello-world.war'
  path ::File.join(Chef::Config[:file_cache_path], 'hello-world.war')
  mode '0644'
  action :create
end

wildfly_deploy_api 'HelloWorld File Deployment' do
  deploy_name "HelloWorld-file-V1"
  runtime_name 'helloworld-file.war'
  parameters 'url' => 'file://' + myapp.path
end
```


# Legacy Resources
* These will be deprecated in the future.  The `wildfly_resource` resource can do everything these can, and via the much faster Management API.  The `deploy_api` resource will replace the `deploy` resource as well.

### Datasource

```ruby
wildfly_datasource 'example' do
  jndiname 'java:jboss/datasource/example'
  drivername 'some-jdbc-driver'
  connectionurl 'jdbc:some://127.0.0.1/example'
  username 'db_username'
  password 'db_password'
  sensitive false
end
```

### Deploy

Allows you to deploy JARs and WARs via chef

Example 1 (from a url)
```ruby
wildfly_deploy 'jboss.jdbc-driver.sqljdbc4_jar' do
      url 'http://artifacts.company.com/artifacts/mssql-java-driver/sqljdbc4.jar'
end
```

Example 2 (from disk)
```ruby
wildfly_deploy 'jboss.jdbc-driver.sqljdbc4_jar' do
      path '/opt/resources/sqljdb4.jar'
end
```

Example 3 with automated update (requires a common runtime_name and version specific name)
```ruby
wildfly_deploy 'my-app-1.0.war' do
      url 'http://artifacts.company.com/artifacts/my-app.1.0.war'
      runtime_name 'my-app.war'
end
```

Example 4 undeploy (use :disable to keep the contents, and :enable to re-deploy previously kept contents)
```ruby
wildfly_deploy 'jboss.jdbc-driver.sqljdbc4_jar' do
      action :remove
end
```

### Attribute LWRP

Allows you to set an attribute in the server config

To change the max-post-size parameter
```xml
            <server name="default-server">
             <http-listener name="default" socket-binding="http" max-post-size="20971520"/>
           <host name="default-host" alias="localhost">

```

```ruby
wildfly_attribute 'max-post-size' do
   path '/subsystem=undertow/server=default-server/http-listener=default'
   parameter 'max-post-size'
   value '20971520L'
   notifies :restart, 'service[wildfly]'
end
```

If the attribute restart is set to false, the wildfly will never restart

```ruby
wildfly_attribute 'max-post-size' do
   path '/subsystem=undertow/server=default-server/http-listener=default'
   parameter 'max-post-size'
   value '20971520L'
   restart false
end
```

You can also add a new attribute

```ruby
wildfly_attribute 'max-post-size' do
   path '/subsystem=mail/mail-session="postbox"'
   parameter 'jndi-name="java:/mail/postbox",debug=true'
   action :add
end
```

### Property LWRP

Allows you to set or delete system properties in the server config. (Supported Actions: :set, :delete)

```ruby
wildfly_property 'Database URL' do
   property 'JdbcUrl'
   value 'jdbc:mysql://1.2.3.4:3306/testdb'
   action :set
   notifies :restart, 'service[wildfly]', :delayed
end
```

# Authors

Author:: Brian Dwyer - Intelligent Digital Services

# Contributors
Contributor:: Hugo Trippaers

Contributor:: Ian Southam
