module Aktion
  module CLI
    class Display
      attr_accessor :indent_count
      def initialize
        @indent_count = 0
        Whirly.configure(spinner: 'dots', stop: '✅', color: false)
      end

      def self.start(&block)
        new.instance_eval(&block)
      end

      def output
        STDOUT
      end

      def tab_size
        2
      end

      def tab_character
        ' '
      end

      def tab
        tab_character * tab_size
      end

      def indentation
        tab * indent_count
      end

      def write(*args)
        output.puts("#{indentation}#{Paint[*args]}")
      end

      def spinner(options = {})
        Whirly.start({ indentation: indentation }.merge(options)) do
          yield(Whirly)
        end
      end

      def indent(times = 1, &block)
        self.indent_count += 1 * times
        yield
        self.indent_count -= 1 * times
      end
    end
  end
end
