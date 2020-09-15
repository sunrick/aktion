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
        PATHS = { 'rails' => 'config/initializers/aktion.rb' }

        desc Paint['Install', :red]

        argument :framework, default: 'rails', desc: 'Framework'

        def call(framework:, **)
          case framework
          when 'rails'
            rails
          else
            Aktion::CLI::Display.start { |d| d.write('invalid') }
          end
        end

        def rails
          Aktion::CLI::Display.start do |display|
            display.spinner(status: 'Configuring Aktion...') do |s|
              File.create(
                source: '/templates/aktion.erb', target: PATHS[framework]
              )
              s.status = "#{s.status} Done!"
            end
            display.indent do
              display.write("Created file: #{PATHS[framework]}")
            end
            UTILS.inject_line_after(
              './app/controllers/application_controller.rb',
              'ApplicationController',
              '  include Aktion::Controller'
            )
          end
        end
      end

      class Create < Dry::CLI::Command
        desc Paint['Generate action', :red]

        argument :module_name, desc: 'Module'
        argument :action, desc: 'Action'

        def call(module_name:, action:, **)
          File.create(
            source: './templates/action.erb',
            target: ".app/actions/#{module_name}/#{action}.rb",
            locals: {
              module_name: module_name.capitalize, action: action.capitalize
            }
          )
          File.create(
            source: './templates/spec.erb',
            target: "./spec/actions/#{module_name}/#{action}_spec.rb",
            locals: { klass: "#{module_name.capitalize}::#{action.capitalize}" }
          )
        end
      end

      module Generate
        class Configuration < Dry::CLI::Command
          desc 'Generate configuration'

          option :apps,
                 type: :array,
                 default: [],
                 desc: 'Generate configuration for specific apps'

          def call(apps:, **)
            puts "generated configuration for apps: #{apps.inspect}"
          end
        end

        class Test < Dry::CLI::Command
          desc 'Generate tests'

          option :framework, default: 'minitest', values: %w[minitest rspec]

          def call(framework:, **)
            puts "generated tests - framework: #{framework}"
          end
        end
      end
    end
  end
end
