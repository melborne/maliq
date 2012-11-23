class CalcTag < Liquid::Tag
  def initialize(tag_name, text, token)
    super
    @text = text
  end

  def render(context)
    if exp = @text.match(/[\s\d\(\)+\*\/-]+/) { $& }
      "#{exp}= #{eval(exp)}"
    else
      ""
    end
  end
end

Liquid::Template.register_tag('calc', CalcTag)
