# Encoding: UTF-8

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
property :service_name,   String, name_property: true
property :base_dir,       String, default: lazy { ::File.join(::File::SEPARATOR, 'opt', service_name) }
property :provision_user, [FalseClass, TrueClass], default: true
property :service_user,   String, default: lazy { service_name }
property :service_group,  String, default: lazy { service_name }
property :version,        String, default: wildfly['version']
property :url,            String, default: wildfly['url']
property :checksum,       String, default: wildfly['checksum']
property :mode,           String, equal_to: %w(domain standalone), default: wildfly['mode']
property :config,         String, default: 'standalone-full.xml'
property :log_dir,        String, default: lazy { ::File.join(base_dir, mode, 'log') }
property :create_mgmt_user, [FalseClass, TrueClass], default: true
# => Launch Arguments passed through to SystemD
property :launch_arguments,  Array, default: []
# => Properties to be dropped into service.properties file
property :server_properties, Array, default: []
# => JPDA Debugging Console
property :jpda_port, String, required: false
# => Management Interface Port
property :bind_management_http, String, default: lazy {
  # => Search Server Properties
  port = server_properties.find { |prop| prop.include? 'jboss.management.http.port' }
  offset = server_properties.find { |prop| prop.include? 'jboss.socket.binding.port-offset' }
  port = port ? port.split('=')[1] : '9990'
  offset = offset ? offset.split('=')[1] : '0'
  (offset.to_i + port.to_i).to_s
}

#
# => Define the Default Resource Action
#
default_action :install

#
# => Define the Install Action
#
action :install do
  #
  # => Deploy the WildFly Application Server
  #

  # => Merge the Config
  wildfly = Chef::Mixin::DeepMerge.merge(node['wildfly'].to_h, node['wildfly'][new_resource.service_name])

  # => Break down SemVer
  _major, _minor, _patch = new_resource.version.split('.').map { |v| String(v) }

  if new_resource.provision_user
    # => Create WildFly System User
    user new_resource.service_user do
      comment 'WildFly System User'
      home new_resource.base_dir
      shell '/sbin/nologin'
      system true
      action [:create, :lock]
    end

    # => Create WildFly Group
    group new_resource.service_group do
      append true
      members new_resource.service_group
      action :create
      only_if { new_resource.service_user != new_resource.service_group }
    end
  end

  # => Create WildFly Directory
  directory "WildFly Base Directory (#{new_resource.service_name})" do
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

  # => Download WildFly Tarball
  wf_tar = remote_file "Download WildFly #{new_resource.version}" do
    path ::File.join(Chef::Config[:file_cache_path], ::File.basename(new_resource.url))
    source new_resource.url
    checksum new_resource.checksum
    retries 2
    action :create
    notifies :run, "bash[Extract WildFly #{new_resource.version}]", :immediately
    not_if { deployed_version? }
  end

  # => Extract WildFly
  bash "Extract WildFly #{new_resource.version}" do
    code <<-EOF
    tar xzf #{wf_tar.path} -C #{new_resource.base_dir} --strip 1
    chown #{new_resource.service_user}:#{new_resource.service_group} -R #{new_resource.base_dir}
    rm -f #{::File.join(new_resource.base_dir, '.chef_deployed')}
    EOF
    action deployed_version? ? :nothing : :run
    notifies :stop, "service[#{new_resource.service_name}]", :before if deployed?
  end

  # => Deploy Service Configuration
  wf_props = file 'WildFly - Service Properties' do
    content new_resource.server_properties.join("\n")
    path ::File.join(new_resource.base_dir, new_resource.mode, 'configuration', 'service.properties')
    owner new_resource.service_user
    group new_resource.service_group
    mode '0640'
    action :create
    notifies :restart, "service[#{new_resource.service_name}]", :delayed
  end

  #
  # => Service Definition
  #
  start_marker = ::File.join(new_resource.base_dir, new_resource.mode, 'tmp', 'startup-marker')

  if node['init_package'] == 'systemd'
    helper = template 'WildFly - SystemD Helper' do
      source 'systemd-helper.sh.erb'
      path ::File.join(new_resource.base_dir, 'bin', 'systemd-helper.sh')
      owner new_resource.service_user
      group new_resource.service_group
      mode '0750'
      cookbook 'wildfly'
      variables(
        start_marker: start_marker,
        timeout: 60
      )
      action :create
    end

    systemd_service new_resource.service_name do
      unit_description 'The WildFly Application Server'
      unit_before %w(httpd.service)
      unit_after %w(syslog.target network.target remote-fs.target nss-lookup.target)
      install_wanted_by 'multi-user.target'
      service do
        service_user new_resource.service_user
        service_group new_resource.service_group
        working_directory new_resource.base_dir
        runtime_directory new_resource.service_name
        environment(
          LAUNCH_JBOSS_IN_BACKGROUND: 1
        )
        pass_environment environment.keys
        exec_start_pre "/bin/rm -f #{start_marker}"
        exec_start [
          ::File.join(new_resource.base_dir, 'bin', new_resource.mode + '.sh'),
          "-c=#{new_resource.config}",
          "-P=#{wf_props.path}",
          new_resource.launch_arguments.join(' '),
        ].join(' ')
        exec_start_post "#{helper.path} start"
        exec_stop_post "#{helper.path} stop"
        exec_reload [
          ::File.join(new_resource.base_dir, 'bin', 'jboss-cli.sh'),
          '--connect',
          "--controller=remote+http://127.0.0.1:#{new_resource.bind_management_http}",
          "-c '#{new_resource.mode == 'domain' ? ':reload-servers' : ':reload'}'",
        ].join(' ')
        nice '-5'.to_i
        private_tmp true
        # standard_output 'null'
      end
      notifies :restart, "service[#{new_resource.service_name}]", :delayed
    end
  else
    template 'WildFly - Service Configuration' do
      source 'wildfly.conf.erb'
      path ::File.join(::File::SEPARATOR, 'etc', 'default', new_resource.service_name)
      cookbook 'wildfly'
      mode '0644'
      variables(
        jboss_home: new_resource.base_dir,
        jboss_user: new_resource.service_user,
        jboss_mode: new_resource.mode,
        jboss_config: new_resource.config,
        jboss_opts: [
          "-P=#{wf_props.path}",
          new_resource.launch_arguments.join(' '),
        ].join(' ')
      )
      action :create
      mode '0644'
      notifies :restart, "service[#{new_resource.service_name}]", :delayed
    end

    template 'WildFly - Init.D Script' do
      case node['platform_family']
      when 'debian'
        source 'wildfly-init-debian.sh.erb'
      when 'rhel', 'amazon'
        source 'wildfly-init-redhat.sh.erb'
      end
      path ::File.join(::File::SEPARATOR, 'etc', 'init.d', new_resource.service_name)
      cookbook 'wildfly'
      owner 'root'
      group 'root'
      mode '0755'
      action :create
      notifies :restart, "service[#{new_resource.service_name}]", :delayed
    end
  end

  # => Configure Logrotate for WildFly
  # template 'Wildfly Logrotate Configuration' do
  #   path ::File.join(::File::SEPARATOR, 'etc', 'logrotate.d', new_resource.service_name)
  #   source 'logrotate.erb'
  #   owner 'root'
  #   group 'root'
  #   mode '0644'
  #   only_if { ::File.directory?(::File.join(::File::SEPARATOR, 'etc', 'logrotate.d')) && wildfly['log']['rotation'] }
  #   action :create
  # end

  # log_dir = ::File.join(::File::SEPARATOR, 'var', 'log', service_name)
  # directory "Log Directory (#{new_resource.service_name})" do
  #   path new_resource.log_dir
  # end

  # logrotate_app service_name do
  #   cookbook 'logrotate'
  #   path [::File.join(log_dir, 'error.log')]
  #   frequency 'daily'
  #   options ['missingok', 'dateext', 'compress', 'notifempty', 'sharedscripts']
  #   postrotate "invoke-rc.d #{service_name} reopen-logs > /dev/null"
  #   rotate 30
  #   create '644 root root'
  # end

  #
  # => WildFly Configuration
  #

  mgmt_user = file 'WildFly - Chef Management User' do
    path ::File.join(new_resource.base_dir, '.chef_user')
    content Chef::JSONCompat.to_json_pretty(WildFly::Helper.wildfly_user) unless ::File.exist?(path)
    sensitive true
    owner 'root'
    group 'root'
    mode '0600'
    action new_resource.create_mgmt_user ? :create : :delete
  end

  if new_resource.create_mgmt_user
    ruby_block 'WildFly - Grab Management User' do
      block do
        user = Chef::JSONCompat.parse(::File.read(mgmt_user.path))
        node.run_state['wf_chef_user_' + new_resource.service_name] = user
      end
      action :run
    end
  end

  # => Configure Wildfly - MGMT Users
  template ::File.join(new_resource.base_dir, new_resource.mode, 'configuration', 'mgmt-users.properties') do
    source 'mgmt-users.properties.erb'
    user new_resource.service_user
    group new_resource.service_group
    cookbook 'wildfly'
    mode '0600'
    variables lazy {
      {
        mgmt_users: wildfly['users']['mgmt'],
        api_user: node.run_state['wf_chef_user_' + new_resource.service_name],
      }
    }
    action :create
  end

  # => Configure Wildfly - Application Users
  template ::File.join(new_resource.base_dir, new_resource.mode, 'configuration', 'application-users.properties') do
    source 'application-users.properties.erb'
    user new_resource.service_user
    group new_resource.service_group
    cookbook 'wildfly'
    mode '0600'
    variables(
      app_users: wildfly['users']['app']
    )
    action :create
  end

  # => Configure Wildfly - Application Roles
  template ::File.join(new_resource.base_dir, new_resource.mode, 'configuration', 'application-roles.properties') do
    source 'application-roles.properties.erb'
    user new_resource.service_user
    group new_resource.service_group
    cookbook 'wildfly'
    mode '0600'
    variables(
      app_roles: wildfly['roles']['app']
    )
    action :create
  end

  # => Configure Java Options
  template ::File.join(new_resource.base_dir, 'bin', "#{new_resource.mode}.conf") do
    source "#{new_resource.mode}.conf.erb"
    user new_resource.service_user
    group new_resource.service_group
    cookbook 'wildfly'
    mode '0644'
    variables(
      xms: wildfly['java_opts']['xms'],
      xmx: wildfly['java_opts']['xmx'],
      xx_metaspacesize: wildfly['java_opts']['xx_metaspacesize'],
      xx_maxmetaspacesize: wildfly['java_opts']['xx_maxmetaspacesize'],
      preferipv4: wildfly['java_opts']['preferipv4'],
      headless: wildfly['java_opts']['headless'],
      jpda: new_resource.jpda_port || false
    )
    action :create
    notifies :restart, "service[#{new_resource.service_name}]", :delayed
  end

  # => Create file to indicate deployment and prevent recurring configuration deployment
  file ::File.join(new_resource.base_dir, '.chef_deployed') do
    content new_resource.version
    mode '0600'
    action :create
  end

  # => Start the WildFly Service
  service new_resource.service_name do
    supports status: true, restart: true, reload: true
    action [:enable, :start]
  end
end

action_class do
  def deployed?
    marker = ::File.join(new_resource.base_dir, '.chef_deployed')
    return false unless ::File.exist?(marker)
    ::File.read(marker)
  end

  def deployed_version?
    deployed? == new_resource.version
  end
end
