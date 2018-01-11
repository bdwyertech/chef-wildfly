# Encoding: UTF-8

# => WildFly Resource - Smoke Test

require_relative '../spec_helper'

# => Verify WildFly Installation
check_wildfly(true, 'wildfly')
check_wildfly(false, 'wildfly2')

# => Make sure the configs make it in
control 'wildfly_config' do
  title 'Verify wildfly_resource Resource'
  cfg = ::File.join(::File::SEPARATOR, 'opt', 'wildfly', 'standalone', 'configuration', 'standalone-full.xml')
  describe file(cfg) do
    it { should be_file }
    its('owner') { should eq 'wildfly' }
    its('group') { should eq 'wildfly' }
    its('mode') { should cmp '0644' }
    its('content') { should match(/test.syslog.local/) }
    its('content') { should match('driver name="mysql" module="com.mysql"') }
    its('content') { should match('java:jboss/datasource/testds') }
    its('content') { should match('java:jboss/datasource/TestMySQLXADS') }
    its('content') { should match('mailuser@gmail.com') }
    its('content') { should match('smtp.gmail.com') }
  end

  # => Verify Management Interface
  describe port(9990) do
    it { should be_listening }
    its('processes') { should include 'java' }
  end
end

control 'wildfly2_config' do
  title 'Verify wildfly_resource Resource'
  cfg = ::File.join(::File::SEPARATOR, 'opt', 'wildfly2', 'standalone', 'configuration', 'standalone-full.xml')
  describe file(cfg) do
    it { should be_file }
    its('owner') { should eq 'wildfly2' }
    its('group') { should eq 'wildfly2' }
    its('mode') { should cmp '0644' }
    its('content') { should match('mailuser@gmail.com') }
    its('content') { should match('property name="SystemName" value="wildfly2"') }
  end

  # => Verify Management Interface
  describe port(9992) do
    it { should be_listening }
    its('processes') { should include 'java' }
  end
end
