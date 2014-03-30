require "thor"

class Maliq::Command < Thor
	
	desc "build [FILES]", "Build a epub file based on markdown or xhtml file(s)"
  option :liquid, aliases:"-l", desc:"Liquid plugin path", type: :string
  option :seq, aliases:"-s", desc:"Build consecutive filenames", :default => true
  option :nav, aliases:"-n", desc:"Create nav.xhtml(TOC)", :default => true
  option :toc, aliases:"-t", desc:"Set title for TOC"
  option :xhtml, aliases:"-x", desc:"Create xhtml files", :default => true
  option :epub, aliases:"-e", desc:"Create a Epub file", :default => true
  option :epub_path, desc:"Epub file path"
  # option :toc, "Add Table of Contents page", :default => true
  def build(*files)
    opts = symbolize_keys(options)
    css = Dir['*.css', '*/*.css']
    opts.update(css: css)
    xhtml = opts.delete(:xhtml)
    epub = opts.delete(:epub)
    epub_path = opts.delete(:epub_path)

    if xhtml
      Maliq::Create.new(files, opts).run!
    end

    if epub
      Maliq::Epub.new(output:epub_path).create!
    end
  rescue => e
    abort "something go wrong: #{e}"
  end

  desc "version", "Show Maliq version"
  def version
    puts "Maliq #{Maliq::VERSION} (c) 2012-2013 kyoendo"
  end
  map "-v" => :version

  desc "banner", "Describe Maliq usage", hide:true
  def banner
    banner = ~<<-EOS
    Maliq is a markdown, liquid converter for EPUB's xhtml.

    Prerequisite:

      1. Set title and language in Yaml Front Matter(YFM) of
      	 your markdown file, which will be used in the header
      	 of generating xhtml.

      2. To parse liquid tags in your markdown, place the plugins
      	 into the sub directory named 'plugins'.

      3. Place css files into the target directory or its 
      	 sub-directory if any.

      4. To split your markdown into several xhtmls for building
      	 chapters, set special markers "<<<--- <filename> --->>>"
      	 into the right places. ex. <<<--- chapter02 --->>>


    Usage:

      maliq build [options] <filenames>

      ex. maliq build chapter01.md

    EOS
    puts banner
    help
  end
  default_task :banner
  map "-h" => :banner

  no_tasks do
    def symbolize_keys(options)
      options.inject({}) do |h, (k,v)|
        h[k.intern] =
          case v
          when Hash then symbolize_keys(v)
          else v
          end
        h
      end
    end
  end
end
