module Maliq
  module FileUtils
    SPLIT_MARKER = /^<<<---\s*([\w\.]+?)\s*--->>>\n/

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

    def split(path, marker=nil)
      marker ||= SPLIT_MARKER
      content = File.read(path)
      filename = File.basename(path, '.*')
      yfm, content = retrieveYFM(content)
      contents = ([filename] + content.split(marker)).to_hash
      contents.with({}) { |(fname, text), h| h[fname] = yfm + text }
    end    

    module_function :split, :retrieveYFM
  end
end

