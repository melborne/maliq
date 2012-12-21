# Maliq::Create receive markdown filename(s)
# and create xhtml file(s).
class Maliq::Create
  def initialize(files, opts={})
    @opts = opts
    @csses = opts.delete(:css)
    @nav = opts.delete(:nav) || opts.delete(:toc)
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
        lastname = fname
      end
    end
  end

  private
  def convert_and_save(md, dest)
    conv = Maliq::Converter.new(md, css:@csses)
    conv.set_meta(liquid:@opts[:liquid]) if @opts[:liquid]
    conv.save(dest)
  end
end
