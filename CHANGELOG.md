WildFly Cookbook CHANGELOG
==========================

# 1.0.1 (2018-2-6)
* Update README
* Add support for Ubuntu on the Supermarket

# 1.0.0 (2018-2-6)
* Rewrite as Resource-Driven Cookbook for added flexibility in deployment
* Add resources for API-based configuration & deployment
* WildFly 11
* Adjust configuration to be primarily based on Java Properties and Launch Configuration.  This means we've removed XML template-driven configuration... The templates were simply clunky and not the ideal way to handle WildFly configuration.

# 0.4.3 (2018-1-5)
* Fix Chef version constraint in metadata

# 0.4.2 (2017-12-15)
* WildFly 10.1
* Add ability to add attributes
* Allow better control of ShellEscape for wildfly_property resource
* Fix for SystemD
* Only deploy Domain configuration in domain mode

# 0.3.1 (2016-04-11)
* Chef will override sensitive back to its global value

# 0.3.0 (2016-02-24)
* Add sensitive and optional username/password parameters to datasource resource.
* Fix missing jboss.jdbc-driver.mysql by restarting Wildfly immediately after installing mysql_connector.
* Add ChefSpec Matchers.

# 0.2.0 (2015-09-09)
* Make install of Java optional.

# 0.1.19 (2015-04-01)
* Fixed location of wildfly.conf in Debian init script.

# 0.1.18 (2015-03-19)
* Adjusted behavior of the service user update procedure.
  * Fixed hardcoded username.
  * Adjusted logic to not fail if user is changed or does not exist... DO NOT CHANGE THE USER AFTER DEPLOYMENT!
  * Touch markerfile if conditions warrant user change.
* Added CHANGELOG.md


# 0.1.17 (2015-03-16)
* Adjusted WildFly service user behavior. We now create a system account (UID reserved range), set home directory to WildFly's base directory, and assign the /sbin/nologin shell
  * Existing installations will only have the home directory and login shell changed, WildFly service will be stopped in order to facilitate this!
* Brought standalone.conf and domain.conf outside of configuration enforcement
* Bumped Java JDK to 8u40


# 0.1.16 (2015-02-04)
* Added support for provisioning domain.conf
* Added ability to set port binding offset
* Switched to JDK8 by default due to JDK7 deprecation
* Bumped MySQL Connector/J to 5.1.34


# 0.1.15 (2014-11-26)
* Bump for WildFly 8.2.0-FINAL


# 0.1.14 (2014-10-22)
* Fixed PostGRES support and added XA datasource support
* Bumped Java JDK to 7u71
* Bumped MySQL Connector/J to 5.1.33


# 0.1.13 (2014-10-22)
* Added support for Debian
  * Contributed by `atoulme`
* Added support for PostGRES
  * Contributed by `atoulme`


# 0.1.12 (2014-09-18)
* Code cleanup
  * Contributed by `rdoorn` and `bjbishop`


# 0.1.11 (2014-09-02)
* Adjusted MySQL Connector/J deployment to restart WildFly upon Connector/J update
* Bumped MySQL Connector/J to 5.1.32


# 0.1.10 (2014-08-25)
* Updated `deploy` provider (Contributed by `rdoorn`)
  * Added undeploy (:remove) action
  * Allow to specify `runtime_name`
  * Automatically deploy new versions of war from URL based on common `runtime_name` (See README for deploy provider, example 3)
  * Bumped Java JDK to 7u67


# 0.1.9 (2014-06-25)
* Set WildFly service resource to run at startup
* Added logcategory and loghandler LWRP's (Contributed by `afornie`)


# 0.1.8 (2014-06-06)
* Added `properties` LWRP to deploy WildFly system properties
* Added logrotate functionality


# 0.1.7 (2014-06-02)
* Bump for WildFly 8.1.0-FINAL
* Bumped Java JDK to 7u60


# 0.1.6 (2014-05-19)
* Bump for WildFly 8.1.0-CR2


# 0.1.5 (2014-05-08)
* Allow the addition of application users and roles (Contributed by `isoutham`)
* Bug fix to datasource and deploy providers to specify shell, as /sbin/nologin should be used for service user in Production (Contributed by `isoutham`)
* Rubocop and FoodCritic fixes (Contributed by `isoutham`)


# 0.1.4 (2014-05-07)
* Added a provider for updating configuration attributes (Contributed by `isoutham`)


# 0.1.3 (2014-04-16)
* Bumped Java JDK to 7u55


# 0.1.2 (2014-04-16)
* Bug fix in templates


# 0.1.1 (2014-04-16)
* Bump for WildFly 8.1.0-CR1


# 0.1.0 (2014-02-18)
* Initial commit
