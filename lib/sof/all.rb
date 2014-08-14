require_relative "members"
require_relative "writer"
require_relative "array"
require_relative "occurence"

Symbol.class_eval do
  def to_sof(io, members)
    io.write ":#{to_s}"
  end
end
NilClass.class_eval do
  def to_sof(io,members)
    io.write "nil"
  end
end
TrueClass.class_eval do
  def to_sof(io , members)
    io.write "true"
  end
end
FalseClass.class_eval do
  def to_sof(io , members)
    io.write "false"
  end
end
String.class_eval do
  def to_sof(io, members)
    io.write self
  end
end
Fixnum.class_eval do
  def to_sof(io , members)
    io.write to_s
  end
end