require 'erb'
require 'dry/cli/utils/files'

module Aktion
  module CLI
    module Commands
      class Version < Dry::CLI::Command
        desc 'Print version'

        def call(*)
          puts '1.0.0'
        end
      end

      class Create < Dry::CLI::Command
        desc Paint['Generate action', :red]

        argument :module_name, desc: 'Module'
        argument :action, desc: 'Action'

        def call(module_name:, action:, **)
          Dry::CLI::Utils::Files.write("./actions/#{module_name}/#{action}.rb",ERB.new(
            File.read(
              File.join(File.dirname(__FILE__), 'templates/aktion.erb')
            )
          ).result_with_hash(
            { module_name: module_name.capitalize, action: action.capitalize }
          ))
          Aktion::CLI::Display.start do
            write module_name
            write action
            write 'dog'
          end
        end
      end

      class Echo < Dry::CLI::Command
        desc Paint['Print input', :red]

        argument :input, desc: 'Input to print'

        example [
                  "             # Prints 'wuh?'",
                  "hello, folks # Prints 'hello, folks'"
                ]

        def call(input: nil, **)
          if input.nil?
            puts 'wuh?'
          else
            Display.create do
              spinner(status: 'Calculating...') do |s|
                sleep 5
                s.status = 'Calculating... Done!'
              end

              indent do
                spinner { sleep 1 }
                write 'hi'
              end

              write 'hi'
              indent do
                write 'hi'
                indent { write 'hi' }
              end
            end
          end
        end
      end

      class Start < Dry::CLI::Command
        desc 'Start Foo machinery'

        argument :root, required: true, desc: 'Root directory'

        example ['path/to/root # Start Foo at root directory']

        def call(root:, **)
          puts "started - root: #{root}"
        end
      end

      class Stop < Dry::CLI::Command
        desc 'Stop Foo machinery'

        option :graceful, type: :boolean, default: true, desc: 'Graceful stop'

        def call(**options)
          puts "stopped - graceful: #{options.fetch(:graceful)}"
        end
      end

      class Exec < Dry::CLI::Command
        desc 'Execute a task'

        argument :task,
                 type: :string, required: true, desc: 'Task to be executed'
        argument :dirs,
                 type: :array, required: false, desc: 'Optional directories'

        def call(task:, dirs: [], **)
          puts "exec - task: #{task}, dirs: #{dirs.inspect}"
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
