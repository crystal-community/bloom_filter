require "../spec_helper"

def random_str
  SecureRandom.random_bytes(rand(20)+5).map(&.chr).join("")
end

describe BloomFilter do
  it "creates optimal correctly" do
    size = 10_000
    expected_probability = 0.05

    filter = BloomFilter::Filter.new_optimal(size, expected_probability)
    size.times { filter.add(random_str) }

    false_positive_count = 0
    size.times do
      false_positive_count += 1 if filter.has?(random_str)
    end

    actual_frequency = false_positive_count.to_f / size
    (0.04..0.06).should contain(actual_frequency)
  end

  it "always returns true if object was insterted" do
    size = 10_000
    expected_probability = 0.05

    filter = BloomFilter::Filter.new_optimal(size, expected_probability)
    strs = [] of String
    size.times do
      strs << random_str
      filter.add(strs.last)
    end

    strs.each do |str|
      filter.has?(str).should eq true
    end
  end


  it "dumps and loads" do
    f1 = BloomFilter::Filter.new(256, 3)
    f1.add("Hello")
    f1.add("Test")
    f1.dump_file("/tmp/crystal_bloom_filter_test")

    f2 = BloomFilter::Filter.load_file("/tmp/crystal_bloom_filter_test")
    f2.hash_num.should eq 3
    f2.bytesize.should eq 256
    f2.bitsize.should eq 256*8
    f2.has?("Hello").should eq true
    f2.has?("Test").should eq true
    f2.has?("None").should eq false
  end
end

