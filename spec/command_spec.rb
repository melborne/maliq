require "spec_helper"

describe Maliq::Command do
  before(:each) do
    @original_dir = Dir.pwd
    Dir.chdir(source_root)
    @md_file = 'book.md'
    @xhtmls = %w(book.xhtml nav.xhtml).map { |f| File.join(destination_root, f) }
  end

  after(:each) do
    FileUtils.rm(Dir["#{destination_root}/*"])
    Dir.chdir(@original_dir)
  end

  describe '#build' do
    it 'creates xhtml files' do
      files = [File.join(source_root, @md_file)]
      Maliq::Command.start(['build', files, '--dir', destination_root])
      expect(@xhtmls.all? { |f| File.exist? f }).to be_true
    end
  end
end