require "../src/bloom_filter"

filter = BloomFilter.new_optimal(2, 0.01)
filter.insert("Esperanto")
filter.dump_file("/tmp/bloom_languages")

loaded_filter = BloomFilter.load_file("/tmp/bloom_languages")
loaded_filter.has?("Esperanto") # => true
loaded_filter.has?("English")   # => false
