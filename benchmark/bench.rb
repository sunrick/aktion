require 'csv'

class Bench
  def self.perform(file, &block)
    new(file).instance_eval(&block)
  end

  attr_reader :file
  def initialize(file)
    @file = file
  end

  def ips(&block)
    bench = Benchmark.ips { |x| yield(x) }
    base_name = File.basename(file, '.rb')
    CSV.open('ips.csv', 'a') do |csv|
      bench.data.map do |row|
        values = row.values
        csv << [
          Time.now.strftime('%Y-%m-%d-%H:%M:%S'),
          base_name,
          values[0],
          values[1]
        ]
      end
    end
  end

  def profile(printer: nil, &block)
    result = RubyProf.profile(track_allocations: true) { yield }
    printer = (printer || RubyProf::CallStackPrinter).new(result)
    path = File.join(File.dirname(file), File.basename(file, '.rb'))
    printer.print(File.open("#{path}.html", 'w'))
  end
end
