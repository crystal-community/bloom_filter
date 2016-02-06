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
    (0.04..0.06).includes?(actual_frequency).should eq true
  end
end

