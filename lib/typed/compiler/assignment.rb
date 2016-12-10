module Typed
  module Assignment

    def on_Assignment( statement )
      #      name , value = *statement
      reset_regs # statements reset registers, ie have all at their disposal
      name_s = no_space statement.name
      value = process(statement.value)
      raise "Not register #{v}" unless value.is_a?(Register::RegisterValue)
      code = get_code( statement , name_s , value)
      raise "must define variable #{name} before using it in #{@method.inspect}" unless code
      add_code code
    end

    private

    def get_code( statement , name_s , value)
      if( index = @method.has_arg(name_s.name))
         # TODO, check type @method.arguments[index].type
        return Register.set_slot(statement , value , :message , Parfait::Message.get_indexed(index) )
      end
      # or a local so it is in the frame
      index = @method.has_local( name_s.name )
      return nil unless index
      # TODO, check type  @method.locals[index].type
      frame = use_reg(:Frame)
      add_code Register.get_slot(statement , :message , :frame , frame )
      return Register.set_slot(statement , value , frame , Parfait::Frame.get_indexed(index) )
    end
  end
end
