require "benchmark"
require "../src/bloom_filter"

N = 100_000_000

filter = BloomFilter.new_optimal(N, 0.000001)

puts "Bloom filter:"
puts "  Size: #{filter.bytesize/1024}Kb"
puts "  Hash functions: #{filter.hash_num}"
puts

res = Benchmark.bm do |x|
  x.report("add")  do
    N.times do
      filter.insert("TheStringHere")
    end
  end

  x.report("has? (present)")  do
    N.times do
      filter.has?("TheStringHere")
    end
  end

  x.report("has? (missing)")  do
    N.times do
      filter.has?("TheMissingStr")
    end
  end
end
