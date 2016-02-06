# Bloom Filter

Implementation of [Bloom Filter](https://en.wikipedia.org/wiki/Bloom_filter) in [Crystal lang](http://crystal-lang.org/).

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
filter.insert("Orange")
filter.insert("Lemon")

# Check elements presence
filter.has?("Orange")  # => true
filter.has?("Lemon")   # => true
filter.has?("Mango")   # => false
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

## Contributors

- [greyblake](https://github.com/greyblake) Potapov Sergey - creator, maintainer
