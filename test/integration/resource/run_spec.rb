# Encoding: UTF-8

# => WildFly Resource - Smoke Test

require_relative '../spec_helper'

# => Verify WildFly Installation
check_wildfly(true, 'wildfly2')

# => Make sure the deployment makes it in
control 'wildfly_config' do
  title 'Verify wildfly_resource Resource'
  cfg = ::File.join(::File::SEPARATOR, 'opt', 'wildfly2', 'standalone', 'configuration', 'standalone-full.xml')
  describe file(cfg) do
    it { should be_file }
    its('owner') { should eq 'wildfly2' }
    its('group') { should eq 'wildfly2' }
    its('mode') { should cmp '0644' }
    its('content') { should match('"jdbc:mysql://1.2.3.4:3306/testdbb123"') }
    its('content') { should_not match(/DummyProperty/) }
    its('content') { should match('helloworld') }
    its('content') { should match('cluster-demo-v1') }
  end

  # => Verify Management Interface
  describe port(9992) do
    it { should be_listening }
    its('processes') { should include 'java' }
  end
end
