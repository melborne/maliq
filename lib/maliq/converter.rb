gem "rdiscount"
autoload :RDiscount, "rdiscount"
require "yaml"
require "liquid"

class Maliq::Converter
  attr_reader :meta
  def initialize(text, opts={})
    @text = text
    @converted = nil
    @meta = { language:'ja', liquid:'plugins' }.merge(opts)
    @engine = ->text{ ::RDiscount.new(text).to_html }
    read_frontmatter
  end
  
  def run(template=:epub)
    text = convert_liquid_tags(@text)
    @converted = apply_template(template) { @engine.call(text) }
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
    if dir = meta[:liquid]
      plugins = File.join(Dir.pwd, dir, '*.rb')
      Dir[plugins].each { |lib| require lib }
    end
    Liquid::Template.parse(text).render
  end

  def apply_template(template, &blk)
    case template
    when nil, false then blk.call
    when :epub then epub_template(&blk)
    else raise "Only :epub template available so far."
    end
  end

  def epub_template(&blk)
    header, footer = ->lang,title,css{ ~<<-HEAD }, ~<<-FOOT
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE html>
      <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="#{lang}">
        <head>
          <title>#{title}</title>
          #{css}
        </head>
        <body>
    HEAD
        </body>
      </html>
    FOOT

    lang, title = meta[:language], meta[:title]
    css = css_link(meta[:css])
    [header[lang, title, css], blk.call, footer].join
  end

  # TODO: indent problem
  def css_link(css)
    template = ->f{ "<link href='#{f}' rel='stylesheet' type='text/css'/>" }
    case css
    when String then template[css]
    when Array then css.map { |f| template[f] }.join("\n")
    else
    end
  end
  
  def read_frontmatter
    @text.match(/^(---\s*\n.*?\n?)^(---\s*$\n?)/m) do |md|
      set_meta( YAML.load(md.to_s).to_symkey )
      @text = md.post_match
    end
  end
end
