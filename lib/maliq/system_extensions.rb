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

  def values_atx(*keys)
    res = values_at(*keys)
    res = res.flatten if res.respond_to?(:flatten)
    res.compact
  end
end

class Array
  def to_hash
    Hash[ *self ]
  end
end

Enumerable.send(:alias_method, :with, :each_with_object)
