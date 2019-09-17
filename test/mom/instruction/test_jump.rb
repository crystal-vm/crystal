require_relative "helper"

module Mom
  class TestJump < MomInstructionTest
    def instruction
      Jump.new( Label.new("ok" , "target"))
    end
    def test_len
      assert_equal 2 , all.length , all_str
    end
    def test_1_slot
      assert_branch risc(1) , "target"
    end
  end
end
