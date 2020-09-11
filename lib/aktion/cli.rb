require 'paint'
require 'whirly'
require 'aktion/cli/display'
require 'aktion/cli/commands'

module Whirly
  def self.render_prefix
    res = ''
    res << "\n" if @options[:position] == 'below'
    res << "\e7" if @options[:ansi_escape_mode] == 'restore'
    res << "\e[G" if @options[:ansi_escape_mode] == 'line'
    res << @options[:indentation] if @options[:indentation]
    res
  end
end

module Aktion
  module CLI
    extend Dry::CLI::Registry

    register 'version', Commands::Version, aliases: %w[v -v --version]
    register 'create', Commands::Create
    register 'echo', Commands::Echo
    register 'start', Commands::Start
    register 'stop', Commands::Stop
    register 'exec', Commands::Exec

    register 'generate', aliases: %w[g] do |prefix|
      prefix.register 'config', Commands::Generate::Configuration
      prefix.register 'test', Commands::Generate::Test
    end
  end
end
