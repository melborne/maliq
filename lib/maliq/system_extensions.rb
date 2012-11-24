class String
  def ~
    margin = scan(/^ +/).map(&:size).min
    gsub(/^ {#{margin}}/, '')
  end

  def basename_with(ext)
    "#{File.basename(self, '.*')}.#{ext}"
  end
end

class Hash
  def to_symkey
    with({}) { |(k, v), h| h[k.intern] = v  }
  end
end

class Array
  def to_hash
    Hash[ *self ]
  end
end

Enumerable.send(:alias_method, :with, :each_with_object)

# class Object
#   def to_nil
#     self if respond_to?(:empty?) && !empty?
#   end
# 
#   def to_nil=(obj)
#     replace(obj) if respond_to?(:replace)
#   end
# end
# 
