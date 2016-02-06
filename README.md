# Bloom Filter

Implementation of [Bloom Filter](https://en.wikipedia.org/wiki/Bloom_filter) in [Crystal lang](http://crystal-lang.org/).

* [Installation](#installation)
* [Usage](#usage)
  * [Basic](#basic)
  * [Creating bloom filter with optimal parameters](#creating-bloom-filter-with-optimal-parameters)
* [Contributors](#contributors)


## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  bloom_filter:
    github: greyblake/crystal-bloom_filter
```


## Usage

### Basic

```crystal
require "bloom_filter"

# Create filter with bitmap size of 32 bytes and 3 hash functions.
filter = BloomFilter.new(bytesize = 32, hash_num = 3)

# Insert elements
filter.insert("Esperanto")
filter.insert("Toki Pona")

# Check elements presence
filter.has?("Esperanto")  # => true
filter.has?("Toki Pona")  # => true
filter.has?("Englsh")     # => false
```

### Creating bloom filter with optimal parameters

Based on your needs(expected number of items and desired probability of false positives),
your can create an optimal bloom filter:

```crystal
# Create a filter, that with one million inserted items, gives 2% of false positives for #has? method
filter = BloomFilter.new_optimal(1_000_000, 0.02)
filter.bytesize # => 1017796 (993Kb)
filter.hash_num # => 6
```

### Dumping to file and loading

It's possible to save existing bloom filter as a binary file and then load it back.

```crystal
filter = BloomFilter.new_optimal(2, 0.01)
filter.insert("Esperanto")
filter.dump_file("/tmp/bloom_languages")

loaded_filter = BloomFilter.load_file("/tmp/bloom_languages")
loaded_filter.has?("Esperanto") # => true
loaded_filter.has?("English")   # => false
```

### Visualizing

If you want to see how your filter looks like, you can visualize it:

```crystal
filter = BloomFilter.new(16, 2)

3.times do |index|
  puts "Number of items: #{index+1}"
  value = "#{index} value"
  filter.insert(value)
  puts filter.visualize
  puts
end
```

Output:
```
Number of items: 1
░░░░░░░░ ░░░░░░░▓ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ▓░░░░░░░ ░░░░░░░░
░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░

Number of items: 2
░░░░░░░░ ░░░░░░░▓ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ▓░░░░░░░ ░░░░░░░░
░░░░░░░░ ░░░░░░▓░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░▓

Number of items: 3
░░░░░░░░ ░░░░░▓░▓ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ▓░░░░░░░ ░░░░░░▓░
░░░░░░░░ ░░░░░░▓░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░▓
```
It may be useful for debug :)


## Contributors

- [greyblake](https://github.com/greyblake) Potapov Sergey - creator, maintainer
