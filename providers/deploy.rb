require 'etc'

# Support whyrun
def whyrun_supported?
  true
end

action :install do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      deploy_install
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::WildflyDeploy.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.path(@new_resource.path)
  @current_resource.url(@new_resource.url)
  @current_resource.exists = false
  @current_resource.cli("--file_path=#{@new_resource.path}")
  if deploy_exists?(@current_resource.name)
    @current_resource.exists = true
  end
  if @current_resource.url != 'nourl'
      @current_resource.cli("--url=#{@new_resource.url}")
  end
end

private

def deploy_exists?(name)
  result = `su #{node['wildfly']['user']} -c "#{node['wildfly']['base']}/bin/jboss-cli.sh -c ' deployment-info --name=#{name}'"`
  $?.exitstatus == 0
end

def deploy_install
  bash "deploy_install" do
    user node['wildfly']['user']
    cwd node['wildfly']['base']
    code <<-EOH
      bin/jboss-cli.sh -c "deploy #{current_resource.cli} --name=#{current_resource.name}"
    EOH
  end
end
