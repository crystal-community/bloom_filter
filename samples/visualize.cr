require "../src/bloom_filter"

filter = BloomFilter.new(16, 2)

3.times do |index|
  puts "Number of items: #{index+1}"
  filter.insert(index.to_s)
  puts filter.visualize
  puts
end
