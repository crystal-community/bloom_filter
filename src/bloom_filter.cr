require "random"
require "./bloom_filter/*"

module BloomFilter
  # Creates optimal filter based number of items and desired false positive probability.
  #
  # n - the number of expected elements to be inserted
  # p - desired false positive probability
  # m - bitsize of the filter
  # k - number of hash functions
  def self.new_optimal(n, p) : Filter
    m = - (n * Math.log(p)) / Math.log(2)**2
    k = (m/n) * Math.log(2)

    bytesize = (m / 8).ceil.to_u32
    k = k.round.to_i

    Filter.new(bytesize, k)
  end

  def self.new(bytesize, hash_num) : Filter
    Filter.new(bytesize.to_u32, hash_num.to_u32)
  end

  def self.load_file(file_path) : Filter
    File.open(file_path, "r") { |fd| load(fd) }
  end

  def self.load(io : IO) : Filter
    Filter.new(io)
  end
end
