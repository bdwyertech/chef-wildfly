# Wildfly Cookbook
Cookbook to deploy Wildfly Java Application Server

# Requirements
Chef Client 11+

Java Opscode Community Cookbook

# Platform
- CentOS, Red Hat

Tested on:
- CentOS 6.6

# Usage
You can add users in the proper format to `attributes\users.rb`

You can customize the Java version, and the Connector/J if you'd like.

If running in production, I STRONGLY recommend you use a wrapper cookbook, and manually specify the Wildfly version, Java version, and cookbook version as well.  This cookbook and configuration templates will continually be updated to support the latest stable release of Wildfly.  Currently, version upgrades will trigger configuration enforcement, meaning any changes made outside of Chef will be wiped out.

# Attributes
* `node['wildfly']['base']` - Base directory to run Wildfly from

* `node['wildfly']['version']` - Specify the version of Wildfly
* `node['wildfly']['url']` - URL to Wildfly tarball
* `node['wildfly']['checksum']` - SHA256 hash of said tarball

* `node['wildfly']['user']` - User to run Wildfly as. DO NOT MODIFY AFTER INSTALLATION!!!
* `node['wildfly']['group']` - Group which owns Wildfly directories
* `node['wildfly']['server']` - Name of service and init.d script for daemonizing

* `node['wildfly']['mysql']['enabled']` - Boolean indicating Connector/J support

* `node['wildfly']['int'][*]` - Various hashes for setting interface & port bindings

* `node['wildfly']['smtp']['host']` - SMTP Destination host
* `node['wildfly']['smtp']['port']` - SMTP Destination port


# Recipes
* `::default` - Installs Java & Wildfly.  Also installs Connector/J if you've got it enabled.
* `::install` - Installs Wildfly.
* `::mysql_connector` - Installs Connector/J into appropriate Wildfly directory.

# Providers

Datasource LWRP

```ruby
wildfly_datasource 'example' do
  jndiname "java:jboss/datasource/example"
  drivername "some-jdbc-driver"
  connectionurl "jdbc:some://127.0.0.1/example"
end
```

Deploy LWRP

Allows you to deploy JARs and WARs via chef

Example 1 (from a url)
```ruby
wildfly_deploy 'jboss.jdbc-driver.sqljdbc4_jar' do
      url "http://artifacts.company.com/artifacts/mssql-java-driver/sqljdbc4.jar"
end
```

Example 2 (from disk)
```ruby
wildfly_deploy 'jboss.jdbc-driver.sqljdbc4_jar' do
      path "/opt/resources/sqljdb4.jar"
end
```

Example 3 with automated update (requires a common runtime_name and version specific name)
```ruby
wildfly_deploy 'my-app-1.0.war' do
      url "http://artifacts.company.com/artifacts/my-app.1.0.war"
      runtime_name "my-app.war"
end
```

Example 4 undeploy (use :disable to keep the contents, and :enable to re-deploy previously kept contents)
```ruby
wildfly_deploy 'jboss.jdbc-driver.sqljdbc4_jar' do
      action :remove
end
```

Attribute LWRP

Allows you to set an attribute in the server config

To change the max-post-size parameter
```xml
            <server name="default-server">
			       <http-listener name="default" socket-binding="http" max-post-size="20971520"/>
				   <host name="default-host" alias="localhost">

```

```ruby
wildfly_attribute "max-post-size" do
   path "/subsystem=undertow/server=default-server/http-listener=default"
   parameter "max-post-size"
   value "20971520L"
   notifies :restart, "service[wildfly]"
end
```

If the attribute restart is set to false, the wildfly will never restart

```ruby
wildfly_attribute "max-post-size" do
   path "/subsystem=undertow/server=default-server/http-listener=default"
   parameter "max-post-size"
   value "20971520L"
   restart false
end
```

Property LWRP

Allows you to set or delete system properties in the server config. (Supported Actions: :set, :delete)

```ruby
wildfly_property "Database URL" do
   property "JdbcUrl"
   value "jdbc:mysql://1.2.3.4:3306/testdb"
   action :set
   notifies :restart, "service[wildfly]", :delayed
end
```

# Authors

Author:: Brian Dwyer - Intelligent Digital Services

# Contributors
Contributor:: Hugo Trippaers

Contributor:: Ian Southam
