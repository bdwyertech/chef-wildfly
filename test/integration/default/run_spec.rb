# Encoding: UTF-8
# WildFly - Smoke Test

require_relative '../spec_helper'

# => Verify WildFly Installation
check_wildfly(true)

# => Ensure MySQL & PostGRES Drivers are Installed
describe command('/opt/wildfly/bin/jboss-cli.sh -c "./subsystem=datasources:installed-drivers-list"') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/com.mysql.jdbc.Driver/) }
  its(:stdout) { should match(/org.postgresql.Driver/) }
  its(:stderr) { should match(/^$/) }
end
