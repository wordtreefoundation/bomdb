# BomDB -- Book of Mormon DB

BomDB is a command-line tool (packaged as a Ruby gem) that provides multiple editions of the Book of Mormon in machine-readable form. At its heart is a sqlite3 database--data can be imported or exported using various formats and options.

## Usage

### SHOW a formatted edition of the Book of Mormon
Let's show the 1992 edition of the Book of Mormon:

```bash
$ bomdb show 1992

1 Nephi 1:1 I, Nephi, having been born of goodly parents, therefore I was taught somewhat in all the learning of my father...
# ... etc ...
Moroni 10:34 And now I bid unto all, farewell.  I soon go to rest in the paradise of God...
```

Or the 1829 printer's manuscript:

```bash
$ bomdb show 1829

1 Nephi 1:1 I Nephi having been born of goodly parents, therefore I was taught somewhat in all the learning of my father...
# ... etc ...
Moroni 10:34 And now I bid unto all farewell. I soon go to rest in the paradise of God...
```
Suppose we want to remove the book, chapter, and verse headings from the output:

```bash
$ bomdb show 1829 --no-verses

I Nephi having been born of goodly parents, therefore I was taught somewhat in all the learning of my father...
# ... etc ...
And now I bid unto all farewell. I soon go to rest in the paradise of God...
```

Exclude verses in the Book of Mormon that are biblical inclusions:

```bash
$ bomdb show 1829 --exclude Bible-OT
# ... shows 6080 verses instead of the usual 6604
```


### IMPORT and EXPORT portions of the database

You can import and export any part of the database, such as the books, verses, editions, and contents (text) of the database.

The github repository contains a set of "starter" json file that are used to seed the database with some reasonable structure and data; however, these json files are absent in the packaged Gem. If you've cloned the github repo, you can re-create the database from scratch:

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
I, Nephi, having been born of goodly parents, therefore I was taught somewhat in all the learning of my father; and having seen many afflictions in the course of my days--nevertheless, having been highly favored of the Lord in all my days; yea, having had a great knowledge of the goodness and the mysteries of God, therefore I make a record of my proceedings in my days; yea, I make a record in the language of my father, which consists of the learning of the Jews and the language of the Egyptians. And I know that the record which I make is true; and I make it with mine own hand; and I make it according to my knowledge.
```

You can automatically align and annotate it:

```bash
$ bomdb align my_typed_bom.txt

# preamble text skipped...
1 Nephi 1:2 yea, I make a record in the language of my father, which consists of the learning of the Jews and the language of the Egyptians. 
1 Nephi 1:3 And I know that the record which I make  is true; and I make it with mine own hand; and I make it according to my knowledge. 
# ... shows 6601 more verses
```

Note that `align` requires the [dwdiff](http://linux.die.net/man/1/dwdiff) command on your system.

## Installation

Ruby 2.1 is required. You should also have a normal build environment set up, e.g. command line tools on the mac, or GCC on Linux.

To install BomDB for use on the command line, use `gem install`:

    $ gem install bomdb

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
