require 'erb'
require 'dry/cli/utils/files'

module Aktion
  module CLI
    UTILS = Dry::CLI::Utils::Files

    class File
      def self.create(source:, target:, locals: {})
        source_content =
          ::File.read(::File.join(::File.dirname(__FILE__), source))
        processed_content = ERB.new(source_content).result_with_hash(locals)
        UTILS.write(target, processed_content)
      end
    end

    module Commands
      class Version < Dry::CLI::Command
        desc 'Print version'
        def call(*)
          puts '1.0.0'
        end
      end

      class Install < Dry::CLI::Command
        def call(**)
          puts 'Installing Aktion...'

          File.create(
            source: '/templates/initializer.erb',
            target: 'config/initializers/aktion.rb'
          )
          puts '  Added initializer at config/initializers/aktion.rb'

          File.create(
            source: '/templates/application_action.erb',
            target: 'app/actions/application_action.rb'
          )
          puts '  Added base ApplicationAction at app/actions/application_action.rb'

          UTILS.inject_line_after(
            'app/controllers/application_controller.rb',
            'ApplicationController',
            '  include Aktion::Controller'
          )
          puts '  Added "include Aktion::Controller" to ApplicationController'
        end
      end

      class Generate < Dry::CLI::Command
        argument :module_name, desc: 'Module'
        argument :action, desc: 'Action'
        def call(module_name:, action:, **)
          puts "Generating #{action}..."

          File.create(
            source: './templates/action.erb',
            target: "app/actions/#{module_name}/#{action}_action.rb",
            locals: {
              module_name: module_name.capitalize,
              action: action.capitalize
            }
          )
          puts "  Created app/actions/#{module_name}/#{action}_action.rb"

          File.create(
            source: './templates/spec.erb',
            target: "./spec/actions/#{module_name}/#{action}_action_spec.rb",
            locals: { klass: "#{module_name.capitalize}::#{action.capitalize}" }
          )
          puts "  Created spec/actions/#{module_name}/#{action}_action_spec.rb"
        end
      end
    end
  end
end
