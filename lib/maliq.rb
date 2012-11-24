require "maliq/version"

module Maliq
  %w(system_extensions converter file_handler).each { |lib| require_relative 'maliq/' + lib }

  # Retrieve Yaml Front Matter from text.
  # Returns [yfm, text]
  def self.retrieveYFM(text)
    yfm = ""
    text.match(/^(---\s*\n.*?\n?)^(---\s*$\n?)/m) do |md|
      yfm = md.to_s
      text = md.post_match
    end
    return yfm, text
  end
end
