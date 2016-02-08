require "../src/bloom_filter"

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
