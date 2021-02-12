class Bench
  def self.perform(&block)
    new.instance_eval(&block)
  end

  def ips(&block)
    Benchmark.ips(&block)
  end

  def profile(file, printer: nil, &block)
    result = RubyProf.profile(track_allocations: true) { yield }
    printer = (printer || RubyProf::CallStackPrinter).new(result)
    path = File.join(File.dirname(file), File.basename(file, '.rb'))
    printer.print(File.open("#{path}.html", 'w'))
  end
end
