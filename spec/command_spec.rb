require "spec_helper"

describe Maliq::Command do
  before(:each) do
    @original_dir = Dir.pwd
    Dir.chdir(source_root)
    @source_files = %w(book.md).map { |f| File.join(source_root, f) }
    @xhtmls = %w(book.xhtml nav.xhtml).map { |f| File.join(source_root, f) }
    @epub = File.join(source_root, 'out.epub')
  end

  after(:each) do
    (@xhtmls + [@epub]).each { |f| FileUtils.rm f if File.exist?(f)}
    Dir.chdir(@original_dir)
  end

  describe '#build' do
    it 'creates xhtml and epub files' do
      Maliq::Command.start(['build', *@source_files])
      expect(@xhtmls.all? { |f| File.exist? f }).to be_true
      expect(File.exist? @epub).to be_true
    end

    it "raises an error without a file" do
      expect{ Maliq::Command.start(['build'])}.to raise_error
    end

    context "set epub option false" do
      it "creates only xhtml files" do
        Maliq::Command.start(['build', *@source_files, '--no-epub'])
        expect(@xhtmls.all? { |f| File.exist? f }).to be_true
        expect(File.exist? @epub).to be_false
      end
    end

    context "set epub path option" do
      it "create epub at specific path" do
        @epub = File.join(destination_root, 'abc.epub')
        Maliq::Command.start(['build', *@source_files, '--epub_path', @epub])
        expect(@xhtmls.all? { |f| File.exist? f }).to be_true
        expect(File.exist? @epub).to be_true
      end
    end
  end
end
