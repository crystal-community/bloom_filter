require "benchmark"
require "../src/bloom_filter"

N      = 100_000_000
STRING = "TheStringHere"

filter = BloomFilter.new_optimal(N, 0.01)

puts
puts "Number of items: #{N}"
puts "Filter size: #{filter.bytesize/1024}Kb"
puts "Hash functions: #{filter.hash_num}"
puts "String size: #{STRING.size}"
puts

res = Benchmark.bm do |x|
  x.report("insert") do
    N.times do
      filter.insert(STRING)
    end
  end

  x.report("has? (present)") do
    N.times do
      filter.has?(STRING)
    end
  end

  x.report("has? (missing)") do
    (N / 5).times do
      # different strings of the same size (13 chars)
      filter.has?("TheMissingStr")
      filter.has?("AnotherString")
      filter.has?("Onemoregoeshe")
      filter.has?("Fourth string")
      filter.has?("5th string!!!")
    end
  end
end
