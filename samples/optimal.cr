require "../src/bloom_filter"

filter = BloomFilter.new_optimal(1_000_000, 0.02)
filter.bytesize # => 1017796 (993Kb)
filter.hash_num # => 6
