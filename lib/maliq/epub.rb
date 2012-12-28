# encoding: UTF-8
require "gepub"

class Maliq::Epub
  def initialize(opts)
    @opts = opts
    @output = @opts.delete(:output) || 'out.epub'
    @path = opts[:path] || '.'
    set_files_by_type(@path)
    @metadata = read_metadata
  end
  
  def create!
    # Instance variables need to be locals, because a block of,
    # GEPUB::Builder.new changes its context with instance_eval.
    metadata = @metadata
    csses  = @csses
    cover_img = @cover_image
    images = @images
    cover_xhtml = @cover_xhtml
    navfile = @navfile
    heading_files = @heading_files
    xhtmls = @xhtmls
    path = @path

    GEPUB::Builder.new do
      metadata.each { |k, *v| send k, *v }

      resources(:workdir => path) {
        csses.each { |f| file f }
        cover_image cover_img if cover_img
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
    end.generate_epub(@output)
  end

  private
  # Returns a Hash, in which filenames are grouped by extname.
  def set_files_by_type(path)
    files = Dir.chdir(path) { Dir["*", "*/*"].group_by { |f| f.ext || :_dir }.to_symkey }
    @mds = files.values_atx(:md, :markdown)
    xhtmls = files.values_atx(:xhtml, :html)
    @csses = files.values_atx(:css)
    images = files.values_atx(:png, :jpg, :jpeg, :gif, :bmp, :tiff)
    (@cover_image, *_), @images =
                images.partition { |f| File.basename(f, '.*').match /^cover/ }

    @cover_xhtml =
      if cover = xhtmls.delete('cover.xhtml')
        cover
      elsif @cover_image
        # Create cover page if page not provided for a cover image.
        create_cover_page(@cover_image)
      end

    @navfile, xhtmls = pick_nav_file(xhtmls)

    @heading_files = get_heading_files(@navfile)

    @xhtmls = xhtmls.map { |f| xhtml_with_heading f }
  end

  # Returns a Hash of metadata.
  def read_metadata
    path = @mds.first
    unless path
      abort "Must exist a markdown filename which have Yaml Front Matter."
    end
    yml, _ = Maliq::FileUtils.retrieveYFM(File.read path)
    return nil if yml.empty?
    metadata = YAML.load(yml).to_symkey

    meta_nodes = GEPUB::Metadata::CONTENT_NODE_LIST + ["unique_identifier"]
    metadata.select { |k, _| meta_nodes.include? k.to_s }
  end

  def create_cover_page(cover)
    out = Maliq::Converter.new("![cover](#{cover})", title:'Cover').run
    StringIO.new(out)
  end

  def pick_nav_file(xhtmls)
    (nav, *_), xhtmls = xhtmls.partition { |fname| fname.match /^(nav|toc)\.x*html$/ }
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
