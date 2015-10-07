require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do

end

Spork.each_run do

end

require "rubygems"
require "bundler/setup"
require 'rspec'
require_relative File.join(File.dirname(__FILE__), "..", "lib/adl15parser")

RSpec.configure do

end
