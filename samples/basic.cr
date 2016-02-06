require "../src/bloom_filter"

# Create filter with bitmap size of 32 bytes and 3 hash functions.
filter = BloomFilter.new(bytesize = 32, hash_num = 3)

# Insert elements
filter.insert("Orange")
filter.insert("Lemon")

# Check elements presence
filter.has?("Orange")  # => true
filter.has?("Lemon")   # => true
filter.has?("Mango")   # => false
