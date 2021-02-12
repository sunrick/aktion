require_relative 'downcase'

result =
  RubyProf.profile(track_allocations: true) do
    DowncaseAction.perform(name: 'Rickard')
  end

printer = RubyProf::CallStackPrinter.new(result)

path = File.join(File.dirname(__FILE__), 'profile.html')

printer.print(File.open(path, 'w'))
