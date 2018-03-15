module Mom

  # SlotLoad is an abstract base class for moving data into a slot
  # A Slot is basically an instance variable, but it must be of known type
  #
  # The value loaded can be a constant (SlotConstant) or come from another Slot (SlotMove)
  #
  # The Slot is the left hand side, the right hand side being determined by the subclass.
  # The only known object (*) for the left side is the current message, which is a bit like
  # the oo version of a PC (program Counter)
  # (* off course all class objects are global, and so they are allowed too)
  #
  # A maybe not immediately obvious corrolar of this design is the total absence of
  # general purpose instance variable accessors. Ie only inside an object's functions
  # can a method access instance variables, because only inside the method is the type
  # guaranteed.
  # From the outside a send is neccessary, both for get and set, (which goes through the method
  # resolution and guarantees the correct method for a type), in other words perfect data hiding.
  #
  # @left: is an array of symbols, that specifies the first the object, and then the Slot.
  #        The first element is either a known type name (Capitalized symbol of the class name) ,
  #        or the symbol :message
  #        And subsequent symbols must be instance variables on the previous type.
  #        Examples:  [:message , :receiver] or [:Space : :next_message]
  #
  # @right: depends on the derived Class
  #
  class SlotLoad < Instruction
    attr_reader :left , :right
    def initialize(left , right)
      left = SlotDefinition.new(left.shift , left) if left.is_a? Array
      @left , @right = left , right
      raise "left not SlotDefinition, #{left}" unless left.is_a? SlotDefinition
    end
  end

  class SlotDefinition
    attr_reader :known_object , :slots
    def initialize( object , slots)
      @known_object , @slots = object , slots
      slot = [slot] unless slot.is_a?(Array)
    end
  end
end
