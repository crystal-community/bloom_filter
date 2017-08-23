require "../src/bloom_filter"

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
