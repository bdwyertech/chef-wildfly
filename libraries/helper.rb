# Encoding: UTF-8

# rubocop: disable AbcSize, LineLength, MethodLength
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
    def jb_cli_cfg(resource_type = 'wildfly', resource_name = 'wildfly')
      rc = Chef.run_context.resource_collection if Chef.run_context
      result = rc.find(resource_type => resource_name) rescue nil # rubocop: disable RescueModifier
      ret = {}
      unless result
        ret['user'] = Chef.node['wildfly']['user']
        ret['cwd']  = Chef.node['wildfly']['base']
        ret['port'] = '9990'
        return ret
      end
      ret['user'] = result.service_user
      ret['cwd']  = result.base_dir
      ret['port'] = result.bind_management_http
      ret
    end

    def jb_cli(cmd, instance = 'wildfly')
      # => Grab Configuration
      cfg = jb_cli_cfg('wildfly', instance)
      Chef::Log.warn("Running JB-CLI(#{cfg['port']}): " + cmd)
      cmd = Mixlib::ShellOut.new("bin/jboss-cli.sh --controller=remote+http://localhost:#{cfg['port']} -c '#{cmd}'")
      cmd.user = cfg['user']
      cmd.cwd  = cfg['cwd']
      cmd.environment = { 'HOME' => ::Dir.home(cmd.user), 'USER' => cmd.user }
      cmd.run_command
      Chef::Log.warn(cmd.stdout)
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
