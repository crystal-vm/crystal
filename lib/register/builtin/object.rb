module Register
  module Builtin
    class Object
      module ClassMethods

        # main entry point, ie __init__ calls this
        # defined here as empty, to be redefined
        def main context
          compiler = Soml::Compiler.new.create_method(:Object , :main , []).init_method
          return compiler.method
        end

      end
      extend ClassMethods
    end
  end
end

require_relative "integer"
require_relative "kernel"
require_relative "word"
