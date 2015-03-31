if defined?(ChefSpec)
  ChefSpec.define_matcher :network_interface
  ChefSpec.define_matcher :rhel_network_interface
  ChefSpec.define_matcher :debian_network_interface
  ChefSpec.define_matcher :win_network_interface

  def create_network_interface(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:network_interface, :create, resource_name)
  end

  def create_rhel_network_interface(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:rhel_network_interface, :create, resource_name)
  end

  def create_debian_network_interface(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:debian_network_interface, :create, resource_name)
  end

  def create_win_network_interface(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:win_network_interface, :create, resource_name)
  end
end
