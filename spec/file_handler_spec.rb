require_relative 'spec_helper'

describe Maliq::FileHandler do
  let(:fhandler) { Maliq::FileHandler }
  describe ".new" do
    before(:each) do
      Dir.mktmpdir do |dir|
        tmpf = "#{dir}/tmp"
        @content = ~<<-EOF
          #hello
          hello
          #Goodbye
          goodbye
          #Yo
          yoyoyo
          EOF
        File.write(tmpf, @content)
        @fh = fhandler.new(tmpf)
      end
    end

    it { @fh.read.should eql @content }
  end

  describe ".split" do
    context "without chapters and front matter" do
      before do
        Dir.mktmpdir do |dir|
          tmpf = "#{dir}/tmp"
          @content = ~<<-EOF
            #hello
            hello
            #Goodbye
            goodbye
            #Yo
            yoyoyo
            EOF
          File.write(tmpf, @content)
          @fh = fhandler.new(tmpf)
        end
      end

      it { @fh.split.should == {'tmp' => @content} }
    end

    context "with chapters" do
      before do
        Dir.mktmpdir do |dir|
          tmpf = "#{dir}/tmp"
          @content = ~<<-EOF
            #hello
            hello
            <<<--- chapter02 --->>>
            #Goodbye
            goodbye
            <<<--- chapter03 --->>>
            #Yo
            yoyoyo
            EOF
          @ch1, @ch2, @ch3 = ~<<-F1, ~<<-F2, ~<<-F3
            #hello
            hello
            F1
            #Goodbye
            goodbye
            F2
            #Yo
            yoyoyo
            F3
          File.write(tmpf, @content)
          @fh = fhandler.new(tmpf)
        end
      end

      it { @fh.split.should == {'tmp' => @ch1, 'chapter02' => @ch2, 'chapter03' => @ch3} }
    end

    context "with chapters and front matter" do
      before do
        Dir.mktmpdir do |dir|
          tmpf = "#{dir}/tmp"
          @content = ~<<-EOF
            ---
            title: Helo, Friends
            ---
            #hello
            hello
            <<<--- chapter02 --->>>
            #Goodbye
            goodbye
            <<<--- chapter03 --->>>
            #Yo
            yoyoyo
            EOF
          @ch1, @ch2, @ch3 = ~<<-F1, ~<<-F2, ~<<-F3
            ---
            title: Helo, Friends
            ---
            #hello
            hello
            F1
            ---
            title: Helo, Friends
            ---
            #Goodbye
            goodbye
            F2
            ---
            title: Helo, Friends
            ---
            #Yo
            yoyoyo
            F3
          File.write(tmpf, @content)
          @fh = fhandler.new(tmpf)
        end
      end

      it { @fh.split.should == {'tmp' => @ch1, 'chapter02' => @ch2, 'chapter03' => @ch3} }
    end
  end
end
