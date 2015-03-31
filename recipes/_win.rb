chef_gem 'ruby-wmi' do
  compile_time true if respond_to?(:compile_time)
end
