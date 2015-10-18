guard 'rspec', cmd: 'rspec' do
  watch('spec/spec_helper.rb') { :rspec }
  watch('lib/adl15parser.rb') { :rspec }
  watch(/lib\/(.+)\.rb/){ |m| "spec/lib/#{m[1]}_spec.rb" }  
  watch(%r{^spec/.+_spec\.rb$})
end

# guard 'spork' do
#   watch('Gemfile.lock')
#   watch('spec/spec_helper.rb') { :rspec }
#   watch('lib/adl15parser.rb') { :rspec }
#   watch(/lib\/(.+)\.rb/){ |m| "spec/lib/#{m[1]}_spec.rb" }
#   watch(%r{^spec/.+_spec\.rb$})
# end
