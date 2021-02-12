require_relative 'downcase'

Benchmark.ips do |x|
  # Typical mode, runs the block as many times as it can
  x.report('class') { Downcase.perform(name: 'Rickard') }
  x.report('aktion') { DowncaseAction.perform(name: 'Rickard') }

  # Compare the iterations per second of the various reports!
  x.compare!
end
