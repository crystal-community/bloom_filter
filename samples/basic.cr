require "../src/bloom_filter"

# Create filter with bitmap size of 32 bytes and 3 hash functions.
filter = BloomFilter.new(bytesize = 32, hash_num = 3)

filter.insert("Esperanto")
filter.insert("Toki Pona")

# Check elements presence
filter.has?("Esperanto") # => true
filter.has?("Toki Pona") # => true
filter.has?("Englsh")    # => false
