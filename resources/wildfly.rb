# Encoding: UTF-8
# rubocop:disable LineLength
#
# Cookbook Name:: wildfly
# Resource:: wildfly
#
# Copyright (C) 2018 Brian Dwyer - Intelligent Digital Services
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# => Shorten Hashes
wildfly = node['wildfly']

# => Define the Resource Name
resource_name :wildfly

# => Define the Resource Properties
property :service_name, String, name_property: true
property :base_dir, String, default: wildfly['base']
property :provision_user, [FalseClass, TrueClass], default: true
property :service_user, String, default: lazy { service_name }
property :service_group, String, default: lazy { service_name }
property :version, String, default: wildfly['version']
property :url, String, default: wildfly['url']
property :checksum, String, default: wildfly['checksum']
property :mode, String, default: wildfly['mode']
property :standalone_conf, String, default: wildfly['sa']['conf']
property :domain_conf, String, default: wildfly['dom']['conf']
# => JPDA Debugging Console
property :jpda_enabled, [FalseClass, TrueClass], default: false
property :jpda_port, String, default: wildfly['jpda']['port']
property :server_opts, Array, default: []
property :server_properties, Array, default: []
# => Interface Bindings
property :bind_public, String, default: '0.0.0.0'
property :bind_public_http, String, default: '8080'
property :bind_public_https, String, default: '8443'
property :bind_management, String, default: '0.0.0.0'
property :bind_offset, [Integer, String], default: 0
property :log_dir, String, default: '/var/log/wildfly/'

#
# => Define the Default Resource Action
#
default_action :install

#
# => Define the Install Action
#
action :install do # rubocop: disable BlockLength
  # =>
  # => Deploy the Wildfly Application Server
  # =>

  # => Merge the Config
  wildfly = Chef::Mixin::DeepMerge.merge(node['wildfly'].to_h, node['wildfly'][new_resource.service_name])

  # => Break down SemVer
  _major, _minor, _patch = new_resource.version.split('.').map { |v| String(v) }

  if new_resource.provision_user
    # => Create Wildfly System User
    user new_resource.service_user do
      comment 'Wildfly System User'
      home new_resource.base_dir
      shell '/sbin/nologin'
      system true
      action [:create, :lock]
    end

    # => Create Wildfly Group
    group new_resource.service_group do
      append true
      members new_resource.service_group
      action :create
      only_if { new_resource.service_user != new_resource.service_group }
    end
  end

  # => Create Wildfly Directory
  directory "Wildfly Base Directory (#{new_resource.service_name})" do
    path new_resource.base_dir
    owner new_resource.service_user
    group new_resource.service_group
    mode '0755'
    recursive true
  end

  # => Ensure LibAIO Present for Java NIO Journal
  case node['platform_family']
  when 'rhel'
    package 'libaio' do
      action :install
    end
  when 'debian'
    package 'libaio1' do
      action :install
    end
  end

  # => Download Wildfly Tarball
  remote_file "Download Wildfly #{new_resource.version}" do
    path ::File.join(Chef::Config[:file_cache_path], "#{new_resource.version}.tar.gz")
    source new_resource.url
    checksum new_resource.checksum
    action :create
    notifies :run, "bash[Extract Wildfly #{new_resource.version}]", :immediately
  end

  # => Extract Wildfly
  bash "Extract Wildfly #{new_resource.version}" do
    cwd Chef::Config[:file_cache_path]
    code <<-EOF
    tar xzf #{new_resource.version}.tar.gz -C #{new_resource.base_dir} --strip 1
    chown #{new_resource.service_user}:#{new_resource.service_group} -R #{new_resource.base_dir}
    rm -f #{::File.join(new_resource.base_dir, '.chef_deployed')}
    EOF
    action ::File.exist?(::File.join(new_resource.base_dir, '.chef_deployed')) ? :nothing : :run
  end

  # Deploy Service Configuration
  wf_cfgdir = directory 'WildFly Configuration Directory' do
    path '/etc/wildfly'
    action :create
  end

  wf_env = template "WildFly Environment #{new_resource.service_name}" do
    source 'systemd/wildfly.conf.erb'
    variables server_opts: new_resource.server_opts,
              config: new_resource.standalone_conf
    path ::File.join(wf_cfgdir.path, new_resource.service_name + '.conf')
    action :create
  end

  wf_props = file 'WildFly Properties' do
    content new_resource.server_properties.join("\n")
    path "/etc/wildfly/#{new_resource.service_name}.properties"
    path ::File.join(wf_cfgdir.path, new_resource.service_name + '.properties')
    action :create
  end

  systemd_service new_resource.service_name do
    unit_description 'The WildFly Application Server'
    unit_before %w[httpd.service]
    unit_after %w[syslog.target network.target remote-fs.target nss-lookup.target]
    install_wanted_by 'multi-user.target'
    service_pid_file "/var/run/wildfly/#{new_resource.service_name}.pid"
    service do
      environment(
        LAUNCH_JBOSS_IN_BACKGROUND: 1
      )
      environment_file "-#{wf_env.path}"
      service_user new_resource.service_user
      service_group new_resource.service_group
      exec_start [
        ::File.join(new_resource.base_dir, 'bin', 'standalone.sh'),
        '-c $WILDFLY_CONFIG',
        '-b $WILDFLY_BIND',
        "-P=#{wf_props.path}"
        # => new_resource.server_opts.join(' ')
      ].join(' ')
      nice '-5'.to_i
      private_tmp true
      # standard_output 'null'
      verify false
    end
    notifies :restart, "service[#{new_resource.service_name}]", :delayed
  end

  # => Configure Logrotate for Wildfly
  template 'Wildfly Logrotate Configuration' do
    path ::File.join(::File::SEPARATOR, 'etc', 'logrotate.d', new_resource.service_name)
    source 'logrotate.erb'
    owner 'root'
    group 'root'
    mode '0644'
    only_if { ::File.directory?(::File.join(::File::SEPARATOR, 'etc', 'logrotate.d')) && wildfly['log']['rotation'] }
    action :create
  end

# =>  log_dir = ::File.join(::File::SEPARATOR, 'var', 'log', service_name)
# =>  directory "Log Directory (#{service_name})" do
# =>    path log_dir
# =>  end
# =>
# =>  logrotate_app service_name do
# =>    cookbook 'logrotate'
# =>    path [::File.join(log_dir, 'error.log')]
# =>    frequency 'daily'
# =>    options ['missingok', 'dateext', 'compress', 'notifempty', 'sharedscripts']
# =>    postrotate "invoke-rc.d #{service_name} reopen-logs > /dev/null"
# =>    rotate 30
# =>    create '644 root root'
# =>  end

  # Create file to indicate deployment and prevent recurring configuration deployment
  file ::File.join(new_resource.base_dir, '.chef_deployed') do
    user new_resource.service_user
    group new_resource.service_group
    action :create_if_missing
  end

  # => Deploy Configuration
  new_resource.run_action(:configure_standalone_mode)

  # => Start the WildFly Service
  service service_name do
    supports status: true, restart: true, reload: true
    action [:enable, :start]
  end
end

# => Define the Configure Standalone Mode Action
action :configure_standalone_mode do
  # =>
  # => Configure Standalone Mode
  # =>

  # => Configure Wildfly Standalone - MGMT Users
  template ::File.join(new_resource.base_dir, 'standalone', 'configuration', 'mgmt-users.properties') do
    source 'mgmt-users.properties.erb'
    user new_resource.service_user
    group new_resource.service_group
    mode '0600'
    variables(
      mgmt_users: wildfly['users']['mgmt']
    )
  end

  # => Configure Wildfly Standalone - Application Users
  template ::File.join(new_resource.base_dir, 'standalone', 'configuration', 'application-users.properties') do
    source 'application-users.properties.erb'
    user new_resource.service_user
    group new_resource.service_group
    mode '0600'
    variables(
      app_users: wildfly['users']['app']
    )
  end

  # => Configure Wildfly Standalone - Application Roles
  template ::File.join(new_resource.base_dir, 'standalone', 'configuration', 'application-roles.properties') do
    source 'application-roles.properties.erb'
    user new_resource.service_user
    group new_resource.service_group
    mode '0600'
    variables(
      app_roles: wildfly['roles']['app']
    )
  end

  # => Configure Java Options - Standalone
  template ::File.join(new_resource.base_dir, 'bin', 'standalone.conf') do
    source 'standalone.conf.erb'
    user new_resource.service_user
    group new_resource.service_group
    mode '0644'
    variables(
      xms: wildfly['java_opts']['xms'],
      xmx: wildfly['java_opts']['xmx'],
      maxpermsize: wildfly['java_opts']['xx_maxpermsize'],
      preferipv4: wildfly['java_opts']['preferipv4'],
      headless: wildfly['java_opts']['headless']
    )
    notifies :restart, "service[#{service_name}]", :delayed
  end
end

action :configure_domain_mode do
  # =>
  # => Configure Domain Mode
  # =>

  # => Configure Wildfly Domain - MGMT Users
  template ::File.join(new_resource.base_dir, 'domain', 'configuration', 'mgmt-users.properties') do
    source 'mgmt-users.properties.erb'
    user new_resource.service_user
    group new_resource.service_group
    mode '0600'
    variables(
      mgmt_users: wildfly['users']['mgmt']
    )
  end

  # => Configure Wildfly Domain - Application Users
  template ::File.join(new_resource.base_dir, 'domain', 'configuration', 'application-users.properties') do
    source 'application-users.properties.erb'
    user new_resource.service_user
    group new_resource.service_group
    mode '0600'
    variables(
      app_users: wildfly['users']['app']
    )
  end

  # => Configure Wildfly Domain - Application Roles
  template ::File.join(new_resource.base_dir, 'domain', 'configuration', 'application-roles.properties') do
    source 'application-roles.properties.erb'
    user new_resource.service_user
    group new_resource.service_group
    mode '0600'
    variables(
      app_roles: wildfly['roles']['app']
    )
  end

  # => Configure Java Options - Domain
  template ::File.join(new_resource.base_dir, 'bin', 'domain.conf') do
    source 'domain.conf.erb'
    user new_resource.service_user
    group new_resource.service_group
    mode '0644'
    variables(
      xms: wildfly['java_opts']['xms'],
      xmx: wildfly['java_opts']['xmx'],
      maxpermsize: wildfly['java_opts']['xx_maxpermsize'],
      preferipv4: wildfly['java_opts']['preferipv4'],
      headless: wildfly['java_opts']['headless']
    )
    notifies :restart, "service[#{service_name}]", :delayed
    only_if { wildfly['mode'] == 'domain' }
  end
end

#######################
### => Universal <= ###
#######################

action_class.class_eval do
  # => Merge the Config
  # def wildfly
  #   Chef::Mixin::DeepMerge.merge(node['wildfly'].to_h, node['wildfly'][new_resource.service_name])
  # end
end

#########################
### => Definitions <= ###
#########################

def parse_json_config(markerfile = nil, servicename = nil)
  return unless markerfile && ::File.exist?(markerfile.to_s) && servicename
  begin
    ::JSON.parse(::File.read(markerfile.to_s), symbolize_names: false)[servicename]
  rescue JSON::ParserError
    return
  end
end
