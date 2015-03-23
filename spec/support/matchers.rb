ChefSpec.define_matcher :modules

def save_modules(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:modules, :save, resource_name)
end
