# encoding: UTF-8
# Maliq::Create receive markdown filename(s)
# and create xhtml file(s).
class Maliq::Create
  def initialize(files, opts={})
    @opts = opts
    @nav = opts.delete(:toc) || opts.delete(:nav)
    @mdfiles = get_markdown_files(files)
  end

  def get_markdown_files(files)
    files.select { |f| f.match /\.(md|markdown)$/ }
        .tap { |res|
          if res.empty?
            abort "Must pass one or more markdown filenames to build xhtml output."
          end
        }
  end
  private :get_markdown_files

  def run!
    lastname = nil
    dirname = nil
    nav_list = []
    @mdfiles.each_with_index do |filename, fno|
      dirname = File.dirname(filename)
      if @opts[:seq] && lastname
        seq_fname = Maliq::FileUtils.create_filename(lastname)
      end

      # Split a file at split markers to several chapters,
      # each of which become a file.
      chapters = Maliq::FileUtils.split(filename)

      chapters.each do |fname, content|
        #this change filenames with sequential names.
        if @opts[:seq] && !fno.zero?
          fname = seq_fname.tap { |s| seq_fname = seq_fname.next }
        end

        dest = File.join(dirname, fname.basename_with(:xhtml))
        convert_and_save(content, dest)
        nav_list << [fname, content]
        lastname = fname
      end
    end
    create_nav_page(nav_list, File.join(dirname, 'nav.xhtml')) if @nav
  end

  private
  def convert_and_save(md_content, dest)
    conv = Maliq::Converter.new(md_content, css:@opts[:css])
    conv.set_meta(liquid:@opts[:liquid]) if @opts[:liquid]
    conv.save(dest)
  end

  def create_nav_page(nav_list, dest)
    nav_list.map! do |fname, content|
      header = File.basename(fname, '.*').capitalize
      content.match(/^\#{1,3}(.*)$/) { header = $1 } # find the first header
      [fname.basename_with(:xhtml), header]
    end

    toc = @nav.is_a?(String) ? @nav : "##目次"

    body = Maliq::Converter.new(~<<-EOS, @opts).run(:epub, 'list' => nav_list)
    <nav epub:type="toc" id="toc">
    #{toc}
    <ol class='toc'>
    {% for ch in list %}
      <li><a href='{{ ch[0] }}'>{{ ch[1] }}</a></li>
    {% endfor %}
    </ol>
    </nav>
    EOS
    body = body.gsub(/<p>(<nav.*?>)<\/p>/, '\1').gsub(/<p>(<\/nav>)<\/p>/, '\1')
    File.write(dest, body)
  end
end
