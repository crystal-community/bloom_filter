require "../src/bloom_filter"

filter = BloomFilter.new(32, 2)

3.times do |index|
  puts "Number of items: #{index+1}"
  value = "#{index*index} Value"
  filter.insert(value)
  puts filter.visualize
  puts
end
