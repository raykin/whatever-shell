# frozen_string_literal: true

require_relative "shell/version"

module Whatever
  module Shell
    class Error < StandardError; end

    module TopMainExt
      def fn(i, &block)
        self.define_singleton_method "shell_#{i}" do
          block.call
        end
      end

      def sfn(i, str)
        self.define_singleton_method "shell_#{i}" do
          system str
        end
      end

      def run
        ARGV.each do |item|
          if item.to_i.to_s == item
            send("shell_#{item}")
          else
            send("shell_#{item}")
          end
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
