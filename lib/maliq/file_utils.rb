require "enumerator"

module Maliq
  module FileUtils
    SPLIT_MARKER = /^<<<---(.*)--->>>\n/

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

    # Split a file with SPLIT_MARKER.
    # Returns a Hash of filename key with its content.
    def split(path, marker=nil)
      marker ||= SPLIT_MARKER
      content = File.read(path)
      filename = File.basename(path, '.*')
      yfm, content = retrieveYFM(content)
      contents = [filename] + content.split(marker)
      prev_name = filename
      contents.each_slice(2).with({}) do |(fname, text), h|
        fname = prev_name = create_filename(prev_name) if fname.strip.empty?
        h[fname.strip] = yfm + text
      end
    end    

    # create filename from previous filename with sequence number.
    def create_filename(prev_name)
      prev_name[/\d+$/] ? prev_name.next : prev_name + '02'
    end

    module_function :split, :retrieveYFM, :create_filename
  end
end

