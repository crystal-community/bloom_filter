require "secure_random"
require "benchmark"
require "../src/bloom_filter"

N = 100_000_000

filter = BloomFilter::Filter.new_optimal(N, 0.01)

puts "Bloom filter:"
puts "  Size: #{filter.bytesize/1024}Kb"
puts "  Hash functions: #{filter.hash_num}"
puts

puts "Generating strings..."
puts

res = Benchmark.bm do |x|
  x.report("add")  do
    N.times do
      filter.add("TheStringHere")
    end
  end

  x.report("has? (present)")  do
    N.times do
      filter.has?("TheStringHere")
    end
  end

  x.report("has? (missing)")  do
    N.times do
      filter.has?("Missing")
    end
  end
end
