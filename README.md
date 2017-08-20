# Bloom Filter [![Build Status](https://travis-ci.org/crystal-community/bloom_filter.svg?branch=master)](https://travis-ci.org/crystal-community/bloom_filter)

Implementation of [Bloom Filter](https://en.wikipedia.org/wiki/Bloom_filter) in [Crystal lang](http://crystal-lang.org/).

* [Installation](#installation)
* [Usage](#usage)
  * [Basic](#basic)
  * [Creating a filter with optimal parameters](#creating-a-filter-with-optimal-parameters)
  * [Dumping to file and loading](#dumping-into-a-file-and-loading)
  * [Union and intersection](#union-and-intersection)
  * [Visualization](#visualization)
* [Benchmark](#benchmark)
* [Contributors](#contributors)


## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  bloom_filter:
    github: crystaliu/bloom_filter
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

### Creating a filter with optimal parameters

Based on your needs(expected number of items and desired probability of false positives),
your can create an optimal bloom filter:

```crystal
# Create a filter, that with one million inserted items, gives 2% of false positives for #has? method
filter = BloomFilter.new_optimal(1_000_000, 0.02)
filter.bytesize # => 1017796 (993Kb)
filter.hash_num # => 6
```

### Dumping into a file and loading

It's possible to save existing bloom filter as a binary file and then load it back.

```crystal
filter = BloomFilter.new_optimal(2, 0.01)
filter.insert("Esperanto")
filter.dump_file("/tmp/bloom_languages")

loaded_filter = BloomFilter.load_file("/tmp/bloom_languages")
loaded_filter.has?("Esperanto") # => true
loaded_filter.has?("English")   # => false
```

### Union and intersection
Having two filters of the same size and number of hash functions, it's possible
to perform union and intersection operations:

```crystal
f1 = BloomFilter.new(32, 3)
f1.insert("Esperanto")
f1.insert("Spanish")

f2 = BloomFilter.new(32, 3)
f2.insert("Esperanto")
f2.insert("English")

# Union
f3 = f1 | f2
f3.has?("Esperanto") # => true
f3.has?("Spanish")   # => true
f3.has?("English")   # => true

# Intersection
f4 = f1 & f2
f4.has?("Esperanto") # => true
f4.has?("Spanish")   # => false
f4.has?("English")   # => false
```

### Visualization

If you want to see how your filter looks like, you can visualize it:

```crystal
f1 = BloomFilter.new(16, 2)
f1.insert("Esperanto")
puts "f1 = (Esperanto)"
puts f1.visualize

f2 = BloomFilter.new(16, 2)
f2.insert("Spanish")
puts "f2 = (Spanish)"
puts f2.visualize

f3 = f1 | f2
puts "f3 = f1 | f2 = (Esperanto, Spanish)"
puts f3.visualize
```

Output:
```
f1 = (Esperanto)
░░░░░░░░ ░░░░░░█░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░
░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░█ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░

f2 = (Spanish)
░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░
░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░█░ ░█░░░░░░

f3 = f1 | f2 = (Esperanto, Spanish)
░░░░░░░░ ░░░░░░█░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░
░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░░ ░░░░░░░█ ░░░░░░░░ ░░░░░░█░ ░█░░░░░░
```
In this way, you can actually see which bits are set:)

## Benchmark
Performance of Bloom filter depends on the following parameters:
* Size of the filter
* Number of hash functions
* Length of the input string

To run benchmark from `./samples/benchmark.cr`, simply run make task:
```
$ make benchmark

Number of items: 100000000
Filter size: 117005Kb
Hash functions: 7
String size: 13

                     user     system      total        real
insert           0.004227   0.000000   0.004227 (  2.769349)
has? (present)   0.007980   0.000000   0.007980 (  5.223778)
has? (missing)   0.004318   0.000000   0.004318 (  2.829521)
```

## Contributors

- [greyblake](https://github.com/greyblake) Potapov Sergey - creator, maintainer
- [funny-falcon](https://github.com/funny-falcon) Sokolov Yura - better hash algorithms
