require 'aktion/cli/commands'

module Aktion
  module CLI
    extend Dry::CLI::Registry

    register 'version', Commands::Version, aliases: %w[v -v --version]
    register 'install', Commands::Install
    register 'generate', Commands::Generate
  end
end
