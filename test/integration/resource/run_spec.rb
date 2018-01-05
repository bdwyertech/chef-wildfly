# Encoding: UTF-8

# => WildFly Resource - Smoke Test

require_relative '../spec_helper'

# => Verify WildFly Installation
check_wildfly(true)

# # => Make sure the configs make it in
# control 'nxlog_config' do
#   title 'Verify nxlog_config Resource'
#   %w(dummy_template.conf test_other_config.conf default.conf).each do |cfg|
#     cfg = ::File.join(::File::SEPARATOR, 'etc', 'nxlog', 'conf.d', cfg)
#
#     describe file(cfg) do
#       it { should be_file }
#       its('owner') { should eq 'root' }
#       its('group') { should eq 'nxlog' }
#       its('mode') { should cmp '0640' }
#     end
#   end
#
#   # => Default Config sets up a Syslog Listener
#   describe port(514) do
#     it { should be_listening }
#     its('processes') { should include 'nxlog' }
#   end
# end
#
