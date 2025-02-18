# frozen_string_literal: true

require_relative "shell/version"

module Whatever
  module Shell
    class Error < StandardError; end

    module TopMainExt
      attr_accessor :available_fns

      def fn(i, &block)
        self.define_singleton_method "shell_#{i}".to_sym, block
        available_fns << i
      end

      def as(i, str)
        self.define_singleton_method("shell_#{i}") do
          system str
        end
        available_fns << i
      end

      def run
        if available_fns.include?(ARGV[0] || '')
          send("shell_#{ARGV[0]}", *ARGV[1..])
        else
          raise Error, "#{ARGV[0]} is not available in command list #{available_fns.to_s}"
        end
      end

      # Try support following syntax by method_missing but cause more troubles
      #   postgres 'ps aux | grep postgresql'
      def experimental_method_missing(mid, *arg, &block)
        # DEV TODO: it's better to limit mid to reduce possible weird errors
        puts mid.inspect
        if block_given?
          self.define_singleton_method "shell_#{mid}" do
            block.call
          end
        else
          self.define_singleton_method "shell_#{mid}" do
            system arg.first
          end
        end
        nil
      end
    end

  end
end

self.class.include Whatever::Shell::TopMainExt
self.available_fns = []
