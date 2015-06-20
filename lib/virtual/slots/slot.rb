module Virtual
  # A slot is a slot in an object. It is the storage location for a value.
  #             (Remember, values are typed)
  # From a memory perspective a slot is an index into an array (the object)
  # We are not modelling the array here, but the index into it.

  # Four known objects exist and those correspond to subclasses:
  # - the message that has been received: MessageSlot
  # - the frame of the method that is executing (local variables): FrameSlot
  # - self as an object: SelfSlot
  # - a message that will be sent, NewMessageSlot

  # additionally frame, self and return are slots in Message and NewMessage

  # Slot has a lot of small subclasses
  # Names for the slots avoid indexes

  class Slot < Object
    MESSAGE_REGISTER = :r0
    SELF_REGISTER = :r1
    FRAME_REGISTER = :r2
    NEW_MESSAGE_REGISTER = :r3

    attr_accessor :index , :type , :value

    private #abstract base class

    def initialize index , type , value
      @index = index
      @type = type
      @value = value
    end
  end

end

require_relative "message_slot"
require_relative "self_slot"
require_relative "frame_slot"
require_relative "new_message_slot"
