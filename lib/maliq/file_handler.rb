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
    yfm, content = retrieveYFM(@content)
    contents = ([@filename] + content.split(@marker)).to_hash
    contents.with({}) { |(fname, text), h| h[fname] = yfm + text }
  end

  # Retrieve Yaml Front Matter from text.
  # Returns [yfm, text]
  def retrieveYFM(text)
    yfm = ""
    text.match(/^(---\s*\n.*?\n?)^(---\s*$\n?)/m) do |md|
      yfm = md.to_s
      text = md.post_match
    end
    return yfm, text
  end
end