# Maliq

Maliq is a markdown, liquid converter for EPUB's xhtml.

It comes with two command 'maliq' and 'maliq\_gepub'. 'maliq' is a markdown-xhtml converter and 'maliq\_gepub' is a wrapper of gepub gem which is a EPUB generator.

## Installation

Add this line to your application's Gemfile:

    gem 'maliq'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install maliq

## Commands Usage

Follow the steps below:

1. Provide your content with markdown format. (ex. chapter01.md)

2. Write meta data required for EPUB in the head of the file with Yaml Front Matter(YFM) form(see below).

3. You can obtain separated xhtml files each of which represents a chapter from a markdown file if needed. This achive by placing a special marker into target line of your content. The Default marker is '<<<--- <filename> --->>>'. (ex. <<<--- chapter02 --->>>)

4. Place css and image files into the directory or its sub directory if any.

5. Place liquid plugins into the sub directory named 'plugins'(default) when your content include liquid tags.

6. Fire up 'maliq' command followed by the filename(s) on the current directory. (ex. maliq chapter01.md) This create xhtml file(s).

7. Install Gepub gem (gem install gepub), then fire up 'maliq_gepub' command to generate a EPUB package.

## Yaml Front Matter Sample
The front matter must be the first thing in the file and takes the form of:

    ---
    language: 'en'
    unique_identifier:
     - 'http:/example.jp/bookid_in_url'
     - 'BookID'
     - 'URL'
    title: 'Book of Charlie'
    subtitle: 'Where Charlie goes to'
    creator: 'melborne'
    date: '2012-01-01'
    ---

Between the triple-dashed lines, you can set predefined variables.

## Liquid plugins
There are many liquid plugins on the Net, but you might need to modify them to be work for Epub generation. Some my modified plugins are there:

> [Liquid filters for Mdpub gem to generate xhtml — Gist](https://gist.github.com/4134497 'Liquid filters for Mdpub gem to generate xhtml — Gist')


## Code Usage

Pass markdown string to `Maliq::Converter.new`.

    puts Maliq::Converter.new("#header1\nline1\n\nline2").run

This get:

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE html>
    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="ja">
      <head>
        <title>#{title}</title>
        
      </head>
      <body>
        <h1>header1</h1>

        <p>line1</p>

        <p>line2</p>
      </body>
    </html>

To make liquid tags parsed with plugins, specify a plugin folder at the front matter or set by `#set_meta`. It is not required when the folder is 'plugins'(default).

    Maliq::Converter.new(<<-EOS).run(false)
    ---
    liquid: 'filters'
    ---
    # header1
    {% calc 2 + 3 %}
    EOS

This produce followings, with calc.rb plugin at a folder named 'filters.

    <h1>header1</h1>

    <p>2 + 3 = 5</p>


## Thank you

Thank you to [Satoshi KOJIMA](https://github.com/skoji) for creating Gepub which is a great EPUB generator.

Thank you to [rtomayko (Ryan Tomayko)](https://github.com/rtomayko) for creating RDiscount which is a great markdown parser.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
