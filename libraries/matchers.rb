# rubocop:disable Style/AccessorMethodName
if defined?(ChefSpec)
  def set_wildfly_attribute(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:wildfly_attribute, :create, resource_name)
  end

  def create_wildfly_datasource(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:wildfly_datasource, :create, resource_name)
  end

  def delete_wildfly_datasource(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:wildfly_datasource, :delete, resource_name)
  end

  def install_wildfly_deploy(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:wildfly_deploy, :install, resource_name)
  end

  def remove_wildfly_deploy(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:wildfly_deploy, :remove, resource_name)
  end

  def enable_wildfly_deploy(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:wildfly_deploy, :enable, resource_name)
  end

  def disable_wildfly_deploy(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:wildfly_deploy, :disable, resource_name)
  end

  def create_wildfly_logcategory(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:wildfly_logcategory, :create, resource_name)
  end

  def delete_wildfly_logcategory(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:wildfly_logcategory, :delete, resource_name)
  end

  def create_wildfly_loghandler(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:wildfly_loghandler, :create, resource_name)
  end

  def delete_wildfly_loghandler(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:wildfly_loghandler, :delete, resource_name)
  end

  def set_wildfly_property(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:wildfly_property, :delete, resource_name)
  end

  def delete_wildfly_property(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:wildfly_property, :delete, resource_name)
  end
end
