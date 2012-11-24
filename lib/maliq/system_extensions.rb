class String
  def ~
    margin = scan(/^ +/).map(&:size).min
    gsub(/^ {#{margin}}/, '')
  end

  # def expand_dirname
  #   File.expand_path(File.dirname self)
  # end
  # 
  # def basename(ext='.*')
  #   File.basename(self, ext)
  # end
  # 
  # def basename_with(ext)
  #   "#{self.expand_dirname}/#{self.basename}.#{ext}"
  # end
  # 
  # def extname
  #   File.extname(self)[/\w+$/].tap { |ext| break ext.intern if ext }
  # end
end

class Hash
  def to_symkey
    Hash[ self.map { |k, v| [k.intern, v] } ]
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
