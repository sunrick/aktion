require_relative './downcase'
require_relative './downcase_action'

# profile the code
RubyProf.start

DowncaseAction.perform(name: 'Rickard')

# ... code to profile ...
result = RubyProf.stop

printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, {})
