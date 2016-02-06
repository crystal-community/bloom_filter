require "../src/bloom_filter"

filter = BloomFilter.new(16, 2)

3.times do |index|
  puts "Number of items: #{index+1}"
  value = "#{index} value"
  filter.insert(value)
  puts filter.visualize
  puts
end
