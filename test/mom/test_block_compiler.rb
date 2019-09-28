require_relative "helper"

module Mom
  class TestBlockCompiler1 < MiniTest::Test
    include ScopeHelper

    def setup
      code = as_main_block("return 5" , "a = 1")
      @risc = RubyX::RubyXCompiler.new(RubyX.default_test_options).ruby_to_risc(code)
    end

    def test_collection
      assert_equal Risc::RiscCollection, @risc.class
    end
    def test_main_compiler
      assert_equal :main , @risc.method_compilers.callable.name
    end
    def test_main_block_compiler
      assert_equal :main , @risc.method_compilers.block_compilers.first.in_method.name
      assert_equal :main_block , @risc.method_compilers.block_compilers.first.callable.name
    end
  end
  class TestBlockCompiler2 < MiniTest::Test
    include ScopeHelper

    def setup
      code = as_main_block("return arg" , "arg = 1")
      @risc = RubyX::RubyXCompiler.new(RubyX.default_test_options).ruby_to_risc(code)
    end

    def test_collection
      assert_equal Risc::RiscCollection, @risc.class
    end
    def test_main_compiler
      assert_equal :main , @risc.method_compilers.callable.name
    end
    def test_main_block_compiler
      assert_equal :main , @risc.method_compilers.block_compilers.first.in_method.name
      assert_equal :main_block , @risc.method_compilers.block_compilers.first.callable.name
    end
  end
end
