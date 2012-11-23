require_relative 'spec_helper'

describe Maliq::Converter do
  let(:converter) { Maliq::Converter }
  before(:each) do
    @header, @footer = ->lang='ja',title=nil{ ~<<-HEAD }, ~<<-FOOT
      <?xml version="1.0" encoding="UTF-8"?>
      <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="#{lang}">
        <head>
          <title>#{title}</title>
          
        </head>
        <body>
      HEAD
        </body>
      </html>
      FOOT
  end

  describe "#run" do
    context "h1 header with some lines" do
      subject { converter.new("#header1\nline1\n\nline2").run }

      it { should eql [@header.call, ~<<-EOS, @footer].join }
        <h1>header1</h1>

        <p>line1</p>

        <p>line2</p>
        EOS
    end

    context "with YAML front matter" do
      subject { converter.new(~<<-EOS).run }
        ---
        title: 'Title of Book'
        language: 'en'
        ---
        # header1
      EOS
      it { should eql [@header['en','Title of Book'], ~<<-EOS, @footer].join }
        <h1>header1</h1>
        EOS
    end

    context "with Liquid tags" do
      subject { converter.new(~<<-EOS).run }
        # header1
        Hello {{ 'tobi' | upcase }}
      EOS
      it { should eql [@header.call, ~<<-EOS, @footer].join }
        <h1>header1</h1>

        <p>Hello TOBI</p>
        EOS
    end

    context "with Liquid plugins" do
      subject { converter.new(~<<-EOS).run }
        ---
        liquid: 'spec/plugins'
        ---
        # header1
        {% calc 2 + 3 %}
      EOS
      it { should eql [@header.call, ~<<-EOS, @footer].join }
        <h1>header1</h1>

        <p>2 + 3 = 5</p>
        EOS
    end
  end
end