require "rspec"
require "maliq"
require "tmpdir"
require "stringio"

module Helpers
  def source_root
    File.join(File.dirname(__FILE__), 'fixtures')
  end

  def destination_root
    File.join(File.dirname(__FILE__), 'sandbox')
  end
end

RSpec.configure do |c|
  c.include Helpers
end
