class String
  def ~
    margin = scan(/^ +/).map(&:size).min
    gsub(/^ {#{margin}}/, '')
  end

  def basename_with(ext)
    "#{File.basename(self, '.*')}.#{ext}"
  end

  def ext
    File.extname(self)[/\w+$/]
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

Enumerable.send(:alias_method, :with, :each_with_object)
