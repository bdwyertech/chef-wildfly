# Encoding: UTF-8

# rubocop: disable AbcSize, MethodLength

#
# => WildFly
#
def check_wildfly(java = false)
  # => Config Test
  if java
    describe command('java -version') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should eq '' }
      its(:stderr) { should match(/java version "1.8/) }
    end
  end

  # => Verify Service
  if os[:family] == 'debian' && os[:release] == '12.04'
    # => 12.04 Hackjob
    describe command('service wildfly status') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/[0-9]/) }
      its(:stderr) { should match(/^$/) }
    end
  else
    describe service('wildfly') do
      it { should be_installed }
      it { should be_enabled }
      it { should be_running }
    end
  end
end
