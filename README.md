# BomDB -- Book of Mormon DB

BomDB is a command-line tool (packaged as a Ruby gem) that provides multiple editions of the Book of Mormon in machine-readable form. At its heart is a sqlite3 database--data can be imported or exported using various formats and options.

See the blog post [DIY Mosiah Priority with BomDB](http://blog.wordtree.org/2015/04/17/diy-mosiah-priority/) for further example usage.

## Usage

### SHOW a formatted edition of the Book of Mormon
Let's show the 1992 edition of the Book of Mormon:

```bash
$ bomdb show --edition=1992

1 Nephi 1:1 I, Nephi, having been born of goodly parents, therefore I was taught somewhat in all the learning of my father...
# ... etc ...
Moroni 10:34 And now I bid unto all, farewell.  I soon go to rest in the paradise of God...
```

Or the 1829 printer's manuscript:

```bash
$ bomdb show --edition=1829

1 Nephi 1:1 I Nephi having been born of goodly parents, therefore I was taught somewhat in all the learning of my father...
# ... etc ...
Moroni 10:34 And now I bid unto all farewell. I soon go to rest in the paradise of God...
```
Suppose we want to remove the book, chapter, and verse headings from the output:

```bash
$ bomdb show --edition=1829 --no-verses

I Nephi having been born of goodly parents, therefore I was taught somewhat in all the learning of my father...
# ... etc ...
And now I bid unto all farewell. I soon go to rest in the paradise of God...
```

Exclude verses in the Book of Mormon that are biblical inclusions:

```bash
$ bomdb show --edition=1829 --exclude Bible-OT
# ... shows 6080 verses instead of the usual 6604
```

Or, show only 1 Nephi, without Old Testament references:

```bash
$ bomdb show '1 Nephi 1-22' --exclude Bible-OT
# ... shows 563 verses in 1st Nephi (1st Nephi has 618 verses,
# but some are from the Old Testament)
```

BomDB uses the [Mericope](https://github.com/wordtreefoundation/mericope) gem to parse scriptural ranges ("pericopes"), so it is quite flexible:

```bash
$ bomdb show 'Mosiah 5:1-2,6'
Mosiah 5:1 And now it came to pass that when king Benjamin had thus spoken...
Mosiah 5:2 And they all cried with one voice, saying: Yea, we believe...
Mosiah 5:6 And now these are the words which king Benjamin desired of them...
```

You can also search for specific terms in the Book of Mormon. Let's search for 'whoso' in 3rd Nephi:

```bash
$ bomdb show --search 'whoso' '3 Nephi 1-30'
```

This shows a color-highlighted result set (note: github markdown does not show color):

3 Nephi 9:14 Yea, verily I say unto you: If ye will come unto me, ye shall have eternal life. Behold, mine arm of mercy is extended towards you. And **whoso**ever will come, him will I receive. And blessed are they which cometh unto me.

3 Nephi 9:20 And ye shall offer for a sacrifice unto me a broken heart and a contrite spirit. And **whoso** cometh unto me with a broken heart and a contrite spirit, him will I baptize with fire and with the Holy Ghost, even as the Lamanites because of their faith in me at the time of their conversion were baptized with fire and with the Holy Ghost--and they knew it not.


[ ... 27 results skipped in this example ... ]


### IMPORT and EXPORT portions of the database

You can import and export any part of the database, such as the books, verses, editions, and contents (text) of the database.

The github repository contains a set of "starter" json files that are used to seed the database with some reasonable structure and data; however, these json files are absent in the packaged Gem. If you've cloned the github repo, you can use these files to re-create the database from scratch:

```bash
$ bundle exec bin/bomdb create
Database file 'bomdb/data/book_of_mormon.db' exists. Delete? (y/N)
y
Created the following tables:
  books
  verses
  editions
  contents
  refs
  notes
Importing books...
Success
Importing verses...
Success
Importing editions...
Success
Importing contents...
Success
Importing refs...
Success
Done.
```

If you have an edition of the Book of Mormon in JSON format that is not present in the database, you can import it, like so:

```bash
$ bomdb import bom-1857.json --type=contents
```

(See the bomdb/data/contents.json file for an example of the expected JSON format)

You can export specific editions in JSON format like so:

```bash
$ bomdb export contents --editions=1829,1830
```

or as text:

```bash
$ bomdb export contents --editions=1829,1830 --format=text
```

(Omit `--editions` altogether and you will get an export of ALL editions.)


### List REFERENCES to Biblical (or other) texts

```bash
$ bomdb references
Bible-NT (2 refs)
Bible-OT (594 refs)
```

```bash
$ bomdb references Bible-NT
1 Corinthians 15:32
Luke 12:19
```


### ALIGN a new Book of Mormon text file

Suppose you have a new Book of Mormon text file that has been scanned from OCR or otherwise entered as a text file. It would take a lot of work to manually align all 6604 verses with the "standard" book, chapter, and verse numbers. Instead, BomDB helps automate this process:

Given this text:

```
I, Nephi, having been born of goodly parents, therefore I was taught somewhat
in all the learning of my father; and having seen many afflictions in the course
of my days--nevertheless, having been highly favored of the Lord in all my days;
yea, having had a great knowledge of the goodness and the mysteries of God,
therefore I make a record of my proceedings in my days; yea, I make a record in
the language of my father, which consists of the learning of the Jews and the
language of the Egyptians. And I know that the record which I make is true; and
I make it with mine own hand; and I make it according to my knowledge.
```

You can automatically align and annotate it:

```bash
$ bomdb align my_typed_bom.txt

1 Nephi 1:1 I, Nephi, having been born of goodly parents, therefore I was taught somewhat in all the learning of my father; and having seen many afflictions in the course of my days--nevertheless, having been highly favored of the Lord in all my days; yea, having had a great knowledge of the goodness and the mysteries of God, therefore I make a record of my proceedings in my days;
1 Nephi 1:2 yea, I make a record in the language of my father, which consists of the learning of the Jews and the language of the Egyptians. 
1 Nephi 1:3 And I know that the record which I make  is true; and I make it with mine own hand; and I make it according to my knowledge. 
```

Note that `align` requires the [dwdiff](http://linux.die.net/man/1/dwdiff) command on your system.

### Custom Queries

Here's a simple way to analyze the Book of Mormon to see the wherefore/therefore divergence leading to the [Mosiah Priority](http://signaturebookslibrary.org/new-approaches-to-the-book-of-mormon-10/) hypothesis (Mosiah was written before 1 Nephi):

```ruby
$ bundle exec irb -rbomdb
irb(main):001:0> q = BomDB::Query.new(exclude: 'Bible-OT')
=> #<BomDB::Query:0x007f90ad1cb408 @edition=1829, @exclude="Bible-OT", @headings=false>
irb(main):002:0> q.books.map do |book,content|
  [book,
   content.scan(/wherefore/i).size,
   content.scan(/therefore/i).size]
end
=> [
     ["1 Nephi", 99, 13], ["2 Nephi", 126, 6], ["Jacob", 53, 1],
     ["Enos", 6, 0], ["Jarom", 3, 0], ["Omni", 6, 0], ["Words of Mormon", 5, 0],
     ["Mosiah", 0, 122], ["Alma", 3, 288], ["Helaman", 0, 63],
     ["3 Nephi", 3, 96], ["4 Nephi", 0, 5], ["Mormon", 0, 22],
     ["Ether", 63, 26], ["Moroni", 38, 0]
   ]
```

Or perhaps a little more visually:
```ruby
require 'bomdb'

q = BomDB::Query.new(exclude: "Bible-OT")

q.books.each do |book,content|
  words = content.scan(/ +/).size
  puts book.ljust(18) +
    'W' * (content.scan(/wherefore/i).size.to_f / words * 2000) +
    'T' * (content.scan(/therefore/i).size.to_f / words * 2000)
end

# 1 Nephi           WWWWWWWWT
# 2 Nephi           WWWWWWWWWWWWWW
# Jacob             WWWWWWWWWWW
# Enos              WWWWWWWWWW
# Jarom             WWWWWWWW
# Omni              WWWWWWWW
# Words of Mormon   WWWWWWWWWWW
# Mosiah            TTTTTTTT
# Alma              TTTTTT
# Helaman           TTTTTT
# 3 Nephi           TTTTTTT
# 4 Nephi           TTTTT
# Mormon            TTTT
# Ether             WWWWWWWTTT
# Moroni            WWWWWWWWWWWW
```

Other possible enumerables on a Query object include:

- books: enumerate on each book of the Book of Mormon
- chapters: enumerate on each book and chapter of the Book of Mormon
- wordgroups(N): enumerate on consecutive N words, e.g. each 1000 words

### Custom Queries and Charts

Let's zoom in on the interesting book, Ether, where the Wherefore/Therefore crossover occurs:

```ruby
require 'bomdb'
require 'google_chart' # gem is called 'gchartrb'

q = BomDB::Query.new(range: 'Ether 1-15')

data = q.chapters.map do |(book, chapter), content|
  words = content.scan(/ +/).size
  wh = content.scan(/wherefore/i).size.to_f / words
  th = content.scan(/therefore/i).size.to_f / words
  [chapter, wh, th]
end

axis_labels = data.map(&:first)
wherefores = data.map{ |d| d[1] }
therefores = data.map{ |d| d[2] }
y_max = [wherefores.max, therefores.max].max
title = 'Wherefores/Therefores Per Word in Ether'

GoogleChart::LineChart.new('600x400', title, false) do |chart|
  chart.data "Wherefores", wherefores, '2200ff'
  chart.show_legend = true
  chart.data "Therefores", therefores, 'ff2200'
  chart.axis :y, range: [0.0, y_max], font_size: 16
  chart.axis :x, range: axis_labels, font_size: 16
  chart.grid x_step: 20.0, y_step: 30.0, length_segment: 1, length_blank: 0
  puts chart.to_url
end
```

![Wherefore/Therefores in Ether](http://chart.apis.google.com/chart?chs=600x400&cht=lc&chco=2200ff,ff2200&chxt=y,x&chxr=0,0.0,0.009721322099805573|1,1,15&chg=20.0,30.0,1.0,0.0&chd=s:AJOOcFpeRaQ8eWX,UJiVcRGFNAAEAAE&chdl=Wherefores|Therefores&chtt=Wherefores/Therefores+Per+Word+in+Ether+by+Chapter)

## Installation

Ruby 2.1 is required. You should also have a normal build environment set up, e.g. command line tools on the mac, or GCC on Linux.

To install BomDB for use on the command line, use `gem install`:

    $ gem install bomdb

To install `dwdiff` on your Mac OS X system: `brew install dwdiff`, or on Ubuntu: `sudo apt-get install dwdiff`.

To include bomdb in another Ruby app, add this line to your application's `Gemfile`:

```ruby
source 'https://rubygems.org'

gem 'bomdb'
```

And then execute:

    $ bundle

## Configuration

Some settings can be configured in a .bomdb file in your home directory:

- db_file: the name of the sqlite database file (defaults to "book_of_mormon.db")
- data_dir: the directory where default data is stored, e.g. the sqlite db
