# BomDB -- Book of Mormon DB

This is a command-line tool (packaged as a Ruby gem) that provides multiple editions of the Book of Mormon in machine-readable form. At its heart is a sqlite3 database--data can be imported or exported using various formats and options.

## Usage

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
$ bomdb show 1829 --no-verse

I Nephi having been born of goodly parents, therefore I was taught somewhat in all the learning of my father...
# ... etc ...
And now I bid unto all farewell. I soon go to rest in the paradise of God...
```

Exclude verses in the Book of Mormon that are biblical inclusions:

```bash
$ bomdb show 1829 --exclude Bible-OT
# ... shows 6080 verses instead of the usual 6604
```

## Installation

Add this line to your application's Gemfile:

```ruby
source 'https://rubygems.org'

gem 'bomdb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bomdb

## Configuration

Some settings can be configured in a .bomdb file in your home directory:

- db_file: the name of the sqlite database file (defaults to "book_of_mormon.db")
- data_dir: the directory where default data is stored, e.g. the sqlite db
