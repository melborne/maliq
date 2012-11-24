gem "rdiscount"
autoload :RDiscount, "rdiscount"
require "yaml"
require "liquid"

class Maliq::Converter
  attr_reader :meta
  def initialize(text)
    @text = text
    @converted = nil
    @meta = { language:'ja', liquid:'plugins' }
    @engine = ->text{ ::RDiscount.new(text).to_html }
    read_frontmatter
  end
  
  def run
    text = convert_liquid_tags(@text)
    @converted = apply_template(:epub) { @engine.call(text) }
  end
  alias :to_xhtml :run
  alias :convert :run

  def save(path="out.xhtml")
    @converted ||= run
    File.write(path, @converted)
  end

  def set_meta(meta)
    @meta.update(meta)
  end

  private
  def convert_liquid_tags(text)
    if dir = @meta[:liquid]
      plugins = File.join(Dir.pwd, dir, '*.rb')
      Dir[plugins].each { |lib| require lib }
    end
    Liquid::Template.parse(text).render
  end

  def apply_template(template, &blk)
    case template
    when :epub then epub_template(&blk)
    else raise "Only :epub template available so far."
    end

  end

  def epub_template(&blk)
    header, footer = ~<<-HEAD, ~<<-FOOT
      <?xml version="1.0" encoding="UTF-8"?>
      <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="#{meta[:language]}">
        <head>
          <title>#{meta[:title]}</title>
          #{meta[:css]}
        </head>
        <body>
    HEAD
        </body>
      </html>
    FOOT
    [header, blk.call, footer].join
  end
  
  def read_frontmatter
    @text.match(/^(---\s*\n.*?\n?)^(---\s*$\n?)/m) do |md|
      @meta.update(YAML.load(md.to_s).to_symkey)
      @text = md.post_match
    end
  end
end
