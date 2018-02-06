# Encoding: UTF-8

#
# Cookbook:: wildfly
# Library:: config
#
# Copyright:: 2018, Brian Dwyer - Intelligent Digital Services
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module WildFly
  # =>
  module Helper
    module_function

    # => Search for a WildFly Instance and grab its Configuration Properties
    def wildfly_cfg(resource_name = 'wildfly')
      resource_type = 'wildfly'

      rc = Chef.run_context.resource_collection if Chef.run_context
      result = rc.find(resource_type => resource_name) rescue nil # rubocop: disable RescueModifier

      cfg = {}
      unless result
        cfg['user']    = Chef.node['wildfly']['user']
        cfg['group']   = Chef.node['wildfly']['group']
        cfg['dir']     = Chef.node['wildfly']['base']
        cfg['service'] = Chef.node['wildfly']['service']
        cfg['port']    = '9990'
        return cfg
      end
      cfg['user']    = result.service_user
      cfg['group']   = result.service_group
      cfg['dir']     = result.base_dir
      cfg['service'] = result.service_name
      cfg['port']    = result.bind_management_http
      cfg
    end

    def wildfly_api_cfg(resource_name = 'wildfly')
      # => Grab the Instance Configuration
      cfg = wildfly_cfg(resource_name)

      # => Grab the Management User
      user = Chef::JSONCompat.parse(::File.read(::File.join(cfg['dir'], '.chef_user'))) rescue {} # rubocop: disable RescueModifier

      cfg['api_url'] = "http://127.0.0.1:#{cfg['port']}/management"
      cfg['api_user'] = user['user'] || 'wildfly'
      cfg['api_pass'] = user['pass'] || 'wildfly'
      cfg
    end

    def wildfly_user(user = nil, pass = nil, realm = 'ManagementRealm')
      user ||= 'chef-wildfly-' + SecureRandom.urlsafe_base64(5)
      pass ||= SecureRandom.urlsafe_base64(40)
      passhash = Digest::MD5.hexdigest "#{user}:#{realm}:#{pass}"
      {
        user: user.to_s,
        pass: pass.to_s,
        passhash: passhash.to_s,
      }
    end

    def jb_cli(cmd, instance = 'wildfly')
      # => Grab Configuration
      cfg = wildfly_cfg(instance)
      Chef::Log.info("Running JB-CLI(#{cfg['port']}): " + cmd)
      cmd = Mixlib::ShellOut.new("bin/jboss-cli.sh --controller=remote+http://127.0.0.1:#{cfg['port']} -c '#{cmd}'")
      cmd.user = cfg['user']
      cmd.cwd  = cfg['dir']
      cmd.environment = { 'HOME' => ::Dir.home(cmd.user), 'USER' => cmd.user }
      cmd.run_command
      Chef::Log.debug(cmd.stdout)
      cmd
    end

    def jb_cli_to_hash(txt)
      # convert_to_hash(result)['result']['value']
      # Transform object string symbols to quoted strings
      txt.gsub!(/([{,]\s*):([^>\s]+)\s*=>/, '\1"\2"=>')

      # Transform object string numbers to quoted strings
      txt.gsub!(/([{,]\s*)([0-9]+\.?[0-9]*)\s*=>/, '\1"\2"=>')

      # Transform object value symbols to quotes strings
      txt.gsub!(/([{,]\s*)(".+?"|[0-9]+\.?[0-9]*)\s*=>\s*:([^,}\s]+\s*)/, '\1\2=>"\3"')

      # Transform array value symbols to quotes strings
      txt.gsub!(/([\[,]\s*):([^,\]\s]+)/, '\1"\2"')

      # Transform object string object value delimiter to colon delimiter
      txt.gsub!(/([{,]\s*)(".+?"|[0-9]+\.?[0-9]*)\s*=>/, '\1\2:')

      JSON.parse(txt) rescue {} # rubocop: disable RescueModifier
    end
  end
end
