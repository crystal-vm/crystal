require_relative "helper"

module Mom
  module Builtin
    class TestWordPut < BootTest
      def setup
        super
        @method = get_word_compiler(:putstring)
      end
      def test_has_get_internal
        assert_equal Mom::MethodCompiler , @method.class
      end
      def test_mom_length
        assert_equal 5 , @method.mom_instructions.length
      end
    end
    class TestWordGet < BootTest
      def setup
        super
        @method = get_word_compiler(:get_internal_byte)
      end
      def test_has_get_internal
        assert_equal Mom::MethodCompiler , @method.class
      end
      def test_mom_length
        assert_equal 5 , @method.mom_instructions.length
      end
    end
    class TestWordSet < BootTest
      def setup
        super
        @method = get_word_compiler(:set_internal_byte)
      end
      def test_has_get_internal
        assert_equal Mom::MethodCompiler , @method.class
      end
      def test_mom_length
        assert_equal 5 , @method.mom_instructions.length
      end
    end
  end
end