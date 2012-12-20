require_relative 'spec_helper'

describe Maliq::Create do
  let(:create) { Maliq::Create }
  before(:each) do
    @header, @footer = ->lang='ja',title=nil{ ~<<-HEAD }, ~<<-FOOT
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE html>
      <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="#{lang}">
        <head>
          <title>#{title}</title>
          <link href='style.css' rel='stylesheet' type='text/css'/>
        </head>
        <body>
      HEAD
        </body>
      </html>
      FOOT
  end

  describe "#run" do
    context "when pass one markdown file with a css" do
      it 'returns one xhtml file with same filename' do
        Dir.mktmpdir do |dir|
          mdfile = "#{dir}/chap1.md"
          cssfile = "#{dir}/style.css"
          File.write(mdfile, ~<<-EOS)
            ---
            title: 'Sample'
            ---
            #title1
            #title2
            EOS
          system 'touch', cssfile
          create.new([mdfile], css:File.basename(cssfile)).run!
          xhtml = "#{dir}/chap1.xhtml"
          File.exist?(xhtml).should be_true
          File.read(xhtml).should eql [@header.call('ja','Sample'), ~<<-EOS, @footer].join
            <h1>title1</h1>

            <h1>title2</h1>
          EOS
        end
      end
    end

    context "when pass one markdown file in which split marker exsist" do
      it "returns two xhtml files" do
        Dir.mktmpdir do |dir|
          mdfile = "#{dir}/chap1.md"
          cssfile = "#{dir}/style.css"
          File.write(mdfile, ~<<-EOS)
            ---
            title: 'Sample'
            ---
            #title1
            <<<------>>>
            #title2
            EOS
          system 'touch', cssfile
          create.new([mdfile], css:File.basename(cssfile)).run!
          xhtml1, xhtml2 = "#{dir}/chap1.xhtml", "#{dir}/chap2.xhtml"
          File.exist?(xhtml1).should be_true
          File.exist?(xhtml2).should be_true
          File.read(xhtml1).should eql [@header.call('ja','Sample'), ~<<-EOS, @footer].join
            <h1>title1</h1>
          EOS
          File.read(xhtml2).should eql [@header.call('ja','Sample'), ~<<-EOS, @footer].join
            <h1>title2</h1>
          EOS
        end
      end
    end
  end
end
