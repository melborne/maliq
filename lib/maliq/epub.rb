# encoding: UTF-8
require "gepub"

class Maliq::Epub
  def initialize(opts)
    @opts = opts
    @files = read_files
    markdowns = @files.values_atx(:md, :markdown)
    @metadata = read_metadata(markdowns.first)
  end
  
  # Returns a Hash, in which filenames are grouped by extname.
  def read_files
    Dir['*', '*/*'].group_by { |f| f.ext || :_dir }.to_symkey
  end

  # Returns a Hash of metadata.
  def read_metadata(path)
    unless path
      abort "Must exist a markdown filename which have Yaml Front Matter."
    end
    yml, _ = Maliq::FileUtils.retrieveYFM(File.read path)
    return nil if yml.empty?
    YAML.load(yml).to_symkey
  end

  def create!
    meta_nodes = GEPUB::Metadata::CONTENT_NODE_LIST + ["unique_identifier"]
    metadata = @metadata.select { |k, _| meta_nodes.include? k.to_s }
    csses  = @files.values_atx(:css)
    images = @files.values_atx(:png, :jpg, :jpeg, :gif, :bmp, :tiff)
    cover_images, images = images.partition { |f| File.basename(f, '.*').match /^cover/ }
    xhtmls = @files.values_atx(:xhtml, :html)
    cover_xhtml = xhtmls.delete('cover.xhtml')

    # Create cover page if page not provided for a cover image.
    if (cover = cover_images.first) && !cover_xhtml
      cover_xhtml = create_cover_page(cover)
    end

    navfile, xhtmls = pick_nav_file(xhtmls)

    heading_files = get_heading_files(navfile)

    xhtmls.map! { |f| xhtml_with_heading f }

    GEPUB::Builder.new do
      metadata.each { |k, v| send k, *Array(v) }

      resources(:workdir => '.') {
        csses.each { |f| file f }
        cover_image cover if cover
        images.each { |f| file(f) }
        ordered {
          if cover_xhtml
            file 'cover.xhtml' => cover_xhtml
            heading 'Cover'
          end

          nav navfile if navfile

          xhtmls.each do |fname, head|
            file fname
            heading head if !navfile || heading_files.include?(fname)
          end
        }
      }
    end.generate_epub(@opts[:output])
  end

  def create_cover_page(cover)
    out = Maliq::Converter.new("![cover](#{cover})", title:'Cover').run
    StringIO.new(out)
  end

  def pick_nav_file(xhtmls)
    navs, xhtmls = xhtmls.partition { |fname| fname.match /^(nav|toc)\.x*html$/ }
    nav = navs.empty? ? nil : navs.first
    return nav, xhtmls
  end

  def get_heading_files(navfile)
    File.read(navfile).scan(/\w+\.xhtml(?=.*?<\/li>)/) if navfile
  end

  def xhtml_with_heading(xhtml)
    heading = File.basename(xhtml, '.*').capitalize
    File.read(xhtml).match(/<h(?:1|2|3)>(.*?)<\/h(?:1|2|3)>/) { heading = $1 }
    [xhtml, heading]
  end
end
