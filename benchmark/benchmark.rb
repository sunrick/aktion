require 'aktion'
require 'benchmark/ips'
require 'ruby-prof'
require 'dry-validation'
require 'active_model'

require_relative 'profiler'

if ARGV[0] == nil
  Dir[File.dirname(__FILE__) + '/**/*.rb'].each { |file| require file }
else
  require_relative "#{ARGV[0]}"
end
