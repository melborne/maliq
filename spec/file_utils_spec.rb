require_relative 'spec_helper'

include Maliq::FileUtils

describe Maliq::FileUtils do
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
          @f = split(tmpf)
        end
      end

      it { @f.should == {'tmp' => @content} }
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
          @f = split(tmpf)
        end
      end

      it { @f.should == {'tmp' => @ch1, 'chapter02' => @ch2, 'chapter03' => @ch3} }
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
          @f = split(tmpf)
        end
      end

      it { @f.should == {'tmp' => @ch1, 'chapter02' => @ch2, 'chapter03' => @ch3} }
    end

    context "with chapters but no name" do
      before do
        Dir.mktmpdir do |dir|
          tmpf = "#{dir}/tmp"
          @content = ~<<-EOF
            #hello
            hello
            <<<------>>>
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
          @f = split(tmpf)
        end
      end

      it { @f.should == {'tmp' => @ch1, 'tmp02' => @ch2, 'chapter03' => @ch3} }
    end

    context "with chapters but no name 2" do
      before do
        Dir.mktmpdir do |dir|
          tmpf = "#{dir}/chapter1"
          @content = ~<<-EOF
            #hello
            hello
            <<<------>>>
            #Goodbye
            goodbye
            <<<--- --->>>
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
          @f = split(tmpf)
        end
      end

      it { @f.should == {'chapter1' => @ch1, 'chapter2' => @ch2, 'chapter3' => @ch3} }
    end
  end
end
