require 'etc'

# Support whyrun
def whyrun_supported?
  true
end

action :set do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already set - nothing to do."
  else
    converge_by("Set #{ @new_resource }") do
      attribute_set
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::WildflyAttribute.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.parameter(@new_resource.parameter)
  @current_resource.value(@new_resource.value)
  @current_resource.restart(@new_resource.restart)
  @current_resource.exists = false
  @current_resource.path(@new_resource.path)
  if attribute_exists?(@current_resource.name)
    @current_resource.exists = true
  else
    # Only notify if restart parameter is true
    if @current_resource.restart
       @new_resource.updated_by_last_action(true) 
    else
       @new_resource.updated_by_last_action(false) 
    end
  end
end

private

def attribute_exists?(name)
  result = `su #{node['wildfly']['user']} -c "#{node['wildfly']['base']}/bin/jboss-cli.sh -c '#{current_resource.path}:read-attribute(name=#{current_resource.parameter})' | grep ' #{current_resource.value}'"`
  $?.exitstatus == 0
end

def attribute_set
  bash "attribute_set" do
    user node['wildfly']['user']
    cwd node['wildfly']['base']
    code <<-EOH
      bin/jboss-cli.sh -c "#{current_resource.path}:write-attribute(name=#{current_resource.parameter},value=#{current_resource.value})"
    EOH
  end
end
