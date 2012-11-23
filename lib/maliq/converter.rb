gem "rdiscount"
autoload :RDiscount, "rdiscount"
require "yaml"
require "liquid"

class Maliq::Converter
  def initialize(text)
    @text = text
    @meta = { language:'ja' }
    @engine = ->text{ ::RDiscount.new(text).to_html }
    read_frontmatter
  end
  
  def run
    text = convert_liquid_tags(@text)
    apply_template { @engine.call(text) }
  end
  alias :to_xhtml :run

  def meta(meta)
    @meta.update(meta)
  end

  private
  def convert_liquid_tags(text)
    if path = @meta[:liquid]
      Dir["#{File.expand_path(path)}/*.rb"].each { |lib| require lib }
    end
    Liquid::Template.parse(text).render
  end

  def apply_template
    header, footer = ~<<-HEAD, ~<<-FOOT
      <?xml version="1.0" encoding="UTF-8"?>
      <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="#{@meta[:language]}">
        <head>
          <title>#{@meta[:title]}</title>
          #{@meta[:css]}
        </head>
        <body>
    HEAD
        </body>
      </html>
    FOOT

    [header, yield, footer].join
  end
  
  def read_frontmatter
    @text.match(/^(---\s*\n.*?\n?)^(---\s*$\n?)/m) do |md|
      @meta.update(YAML.load(md.to_s).to_symkey)
      @text = md.post_match
    end
  end
end
