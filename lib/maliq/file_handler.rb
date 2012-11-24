class Maliq::FileHandler
  attr_accessor :marker
  def initialize(path)
    @path = path
    @filename = File.basename(path, '.*')
    @content = File.read(path)
    @marker = /^<<<---\s*([[:word:]]+?)\s*--->>>\n/
  end

  def read
    @content
  end

  # Split a text with @marker.
  # Returns a hash with name and its content.
  def split
    yfm, content = Maliq.retrieveYFM(@content)
    contents = ([@filename] + content.split(@marker)).to_hash
    contents.with({}) { |(fname, text), h| h[fname] = yfm + text }
  end
end
