module Risc
  # To create a binary, we need a so called Text element. Bad name for what is the code
  #
  # Binary code is already created by the Machine (by translating risc to arm to binary)
  #
  # This class serves to write all the objects of the machine (wich also contain the code)
  # into one stream or binary text object. This is then written to an ELF text section.
  #

  class TextWriter
    include Logging
    log_level :info

    MARKER = 0xA51AF00D

    def initialize( machine)
      @machine = machine
      @objects = machine.objects
      @load_at = 0x8054 # this is linux/arm
    end

    # objects must be written in same order as positioned by the machine, namely
    # - intial jump
    # - all objects
    # - all BinaryCode
    def write_as_string
      @stream = StringIO.new
      write_any(@machine.binary_init)
      write_debug
      write_objects
      write_code
      log.debug "Assembled 0x#{stream_position.to_s(16)} bytes"
      return @stream.string
    end

    # debugging loop to write out positions (in debug)
    def write_debug
      @objects.each do |id , objekt|
        next if objekt.is_a?(Risc::Label)
        log.debug "Linked #{objekt.class}:0x#{objekt.object_id.to_s(16)} at 0x#{Positioned.position(objekt).to_s(16)} / 0x#{objekt.padded_length.to_s(16)}"
      end
    end

    # Write all the objects
    def write_objects
      #  then the objects , not code yet
      @objects.each do | id, objekt|
        next if objekt.is_a? Parfait::BinaryCode
        next if objekt.is_a? Risc::Label # ignore
        write_any( objekt )
      end
    end

    # Write the BinaryCode objects of all methods to stream.
    # Really like any other object, it's just about the ordering
    def write_code
      @objects.each do |id, method|
        next unless method.is_a? Parfait::TypedMethod
        binary = method.binary
        while(binary) do
          write_any( binary )
          binary = binary.next
        end
      end
    end

    # Write any object just logs a bit and passes to write_any_out
    def write_any( obj )
      write_any_log( obj ,  "Write")
      if @stream.length != Positioned.position(obj)
        raise "Write #{obj.class}:0x#{obj.object_id.to_s(16)} at 0x#{stream_position.to_s(16)} not 0x#{Positioned.position(obj).to_s(16)}"
      end
      write_any_out(obj)
      write_any_log( obj ,  "Wrote")
      Positioned.position(obj)
    end

    def write_any_log( obj , at)
      log.debug "#{at} #{obj.class}:0x#{obj.object_id.to_s(16)} at stream 0x#{stream_position.to_s(16)} pos:0x#{Positioned.position(obj).to_s(16)} , len:0x#{obj.padded_length.to_s(16)}"
    end

    # Most objects are the same and get passed to write_object
    # But Strings and BinaryCode write out binary, so they have different methods (for now)
    def write_any_out(obj)
      case obj
      when Parfait::Word, Symbol
        write_String obj
      when Parfait::BinaryCode
        write_BinaryCode obj
      when Parfait::Data2
        write_data2 obj
      else
        write_object obj
      end
    end

    # write type of the instance, and the variables that are passed
    # variables ar values, ie int or refs. For refs the object needs to save the object first
    def write_object( object )
      write_object_check(object)
      obj_written = write_object_variables(object)
      log.debug "instances=#{object.get_instance_variables.inspect} mem_len=0x#{object.padded_length.to_s(16)}"
      indexed_written = write_object_indexed(object)
      log.debug "type #{obj_written} , total #{obj_written + indexed_written} (array #{indexed_written})"
      log.debug "Len = 0x#{object.get_length.to_s(16)} , inst =0x#{object.get_type.instance_length.to_s(16)}" if object.is_a? Parfait::Type
      pad_after( obj_written + indexed_written  )
      Positioned.position(object)
    end

    def write_object_check(object)
      log.debug "Write object #{object.class} #{object.inspect[0..100]}"
      #Only initially created codes are collected. Binary_init and method "tails" not
      if !@objects.has_key?(object.object_id) and !object.is_a?(Parfait::BinaryCode)
        log.debug "Object at 0x#{Positioned.position(object).to_s(16)}:#{object.get_type()}"
        raise "Object(0x#{object.object_id.to_s(16)}) not linked #{object.inspect}"
      end
    end

    def write_object_indexed(object)
      written = 0
      if( object.is_a? Parfait::List)
        object.each do |inst|
          write_ref_for(inst)
          written += 4
        end
      end
      written
    end

    def write_object_variables(object)
      @stream.write_signed_int_32( MARKER  )
      written = 0 # compensate for the "secret" marker
      object.get_instance_variables.each do |var|
        inst = object.get_instance_variable(var)
        #puts "Nil for #{object.class}.#{var}" unless inst
        inst = nil if [:cpu_instructions , :risc_instructions].include?(var)
        write_ref_for(inst)
        written += 4
      end
      written
    end

    def write_data2( code )
      @stream.write_signed_int_32( MARKER  )
      write_ref_for( code.get_type )
      log.debug "Data2 witten stream 0x#{@stream.length.to_s(16)}"
    end

    def write_BinaryCode( code )
      @stream.write_signed_int_32( MARKER  )
      write_ref_for( code.get_type )
      write_ref_for( code.next )
      code.each_word do |word|
        @stream.write_unsigned_int_32( word || 0 )
      end
      log.debug "Code16 witten stream 0x#{@stream.length.to_s(16)}"
    end

    def write_String( string )
      if string.is_a? Parfait::Word
        str = string.to_string
        raise "length mismatch #{str.length} != #{string.char_length}" if str.length != string.char_length
      end
      str = string.to_s if string.is_a? Symbol
      log.debug "#{string.class} is #{string} at 0x#{Positioned.position(string).to_s(16)} length 0x#{string.length.to_s(16)}"
      write_checked_string(string , str)
    end

    def write_checked_string(string, str)
      @stream.write_signed_int_32( MARKER  )
      write_ref_for( string.get_type ) #ref
      @stream.write_signed_int_32( str.length  ) #int
      @stream.write str
      pad_after(str.length + 8 ) # type , length   *4 == 12
      log.debug "String (0x#{string.length.to_s(16)}) stream 0x#{@stream.length.to_s(16)}"
    end

    def write_Symbol(sym)
      return write_String(sym)
    end

    private

    # write means we write the resulting address straight into the assembler stream
    # object means the object of which we write the address
    def write_ref_for object
      case object
      when nil
        @stream.write_signed_int_32(0)
      when Fixnum
        @stream.write_signed_int_32(object)
      else
        @stream.write_signed_int_32(Positioned.position(object) + @load_at)
      end
    end

    # pad_after is always in bytes and pads (writes 0's) up to the next 8 word boundary
    def pad_after( length )
      before = stream_position
      pad = Padding.padding_for(length) - 4  # four is for the MARKER we write
      pad.times do
        @stream.write_unsigned_int_8(0)
      end
      after = stream_position
      log.debug "padded 0x#{length.to_s(16)} with 0x#{pad.to_s(16)} stream #{before.to_s(16)}/#{after.to_s(16)}"
    end

    # return the stream length as hex
    def stream_position
      @stream.length
    end
  end

  RxFile::Volotile.add(TextWriter , [:objects])
end
