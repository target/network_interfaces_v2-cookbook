# guard 'spork' do
#   watch('Gemfile')
#   watch('spec/spec_helper.rb')     { :rspec }
#   watch(%r{^spec/support/.+\.rb$}) { :rspec }
# end

guard 'rspec', cmd: 'bundle exec rspec', all_on_start: true, all_after_pass: false do
  watch(%r{^spec/libraries/.+_spec\.rb$})
  watch(%r{^spec/helper_recipes/.+_spec\.rb$})

  watch(%r{^libraries/(.+)\.rb$})   { |m| "spec/libraries/#{m[1]}_spec.rb" }
  watch(%r{^test/fixtures/cookbooks/fake/recipes/(.+)\.rb$}) { |m| "spec/helper_recipes/fake_#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')      { 'spec' }
end
