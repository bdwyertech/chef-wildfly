# frozen_string_literal: true

# encoding: UTF-8

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  # => Hostname
  config.vm.hostname = 'wildfly'

  # => Base Box
  config.vm.box = 'CentOS7_x64'
  # config.vm.box = 'Ubuntu16.04_x64'

  # => Chef Omnibus Updater
  if Vagrant.has_plugin?('vagrant-omnibus')
    config.omnibus.chef_version = '12.21.31' # => :latest
  end

  # => Vagrant HostManager Configuration
  if Vagrant.has_plugin?('vagrant-hostmanager')
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true # => Manages local machine's /etc/hosts
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
    # => config.hostmanager.aliases = ["#{config.vm.hostname}.bdwyertech.net"]
  end

  config.vm.network :forwarded_port, guest: 8080, host: 8080
  config.vm.network :forwarded_port, guest: 9990, host: 9990

  config.vm.network :public_network

  config.vm.provision :chef_solo do |chef|
    # => chef.log_level = :debug
    chef.json = {}

    chef.run_list = [
      'recipe[wildfly::default]',
    ]
  end

  # => VMware Customization
  %w(vmware_workstation vmware_fusion).each do |platform|
    config.vm.provider platform do |v|
      v.vmx['memsize'] = '4096'
      v.vmx['numvcpus'] = '4'
    end
  end
end
