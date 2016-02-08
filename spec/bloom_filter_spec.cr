require "./spec_helper"

def random_str
  SecureRandom.random_bytes(rand(20)+5).map(&.chr).join("")
end

describe BloomFilter do
  it "creates optimal correctly" do
    size = 10_000
    expected_probability = 0.05

    filter = BloomFilter.new_optimal(size, expected_probability)
    size.times { filter.insert(random_str) }

    false_positive_count = 0
    size.times do
      false_positive_count += 1 if filter.has?(random_str)
    end

    actual_frequency = false_positive_count.to_f / size
    (0.04..0.06).should contain(actual_frequency)
  end

  it "always returns true if object was inserted" do
    size = 10_000
    expected_probability = 0.05

    filter = BloomFilter.new_optimal(size, expected_probability)
    strs = [] of String
    size.times do
      strs << random_str
      filter.insert(strs.last)
    end

    strs.each do |str|
      filter.has?(str).should eq true
    end
  end

  it "dumps and loads" do
    f1 = BloomFilter.new(256, 3)
    f1.insert("Hello")
    f1.insert("Test")
    f1.dump_file("/tmp/crystal_bloom_filter_test")

    f2 = BloomFilter.load_file("/tmp/crystal_bloom_filter_test")
    f2.hash_num.should eq 3
    f2.bytesize.should eq 256
    f2.bitsize.should eq 256*8
    f2.has?("Hello").should eq true
    f2.has?("Test").should eq true
    f2.has?("None").should eq false
  end

  describe "#==" do
    context "bytesize does not match" do
      it "returns false" do
        f1 = BloomFilter.new(32, 2)
        f2 = BloomFilter.new(36, 2)
        f1.should_not eq f2
      end
    end

    context "number of hashes does not match" do
      it "returns false" do
        f1 = BloomFilter.new(32, 2)
        f2 = BloomFilter.new(32, 3)
        f1.should_not eq f2
      end
    end

    context "bitmap does not match" do
      it "returns false" do
        f1 = BloomFilter.new(32, 2)
        f1.insert("Data")
        f2 = BloomFilter.new(32, 2)
        f1.should_not eq f2
      end
    end

    context "everything matches" do
      it "returns true" do
        f1 = BloomFilter.new(32, 2)
        f1.insert("Data")
        f2 = BloomFilter.new(32, 2)
        f2.insert("Data")
        f1.should eq f2
      end
    end
  end

  describe "#|" do
    context "when filters have different size" do
      it "raises ArgumentError" do
        f1 = BloomFilter.new(4, 1)
        f2 = BloomFilter.new(8, 1)
        expect_raises(ArgumentError, "Cannot unite filters of different size") do
          f1 | f2
        end
      end
    end

    context "when filters have different number of hash functions" do
      it "raises ArgumentError" do
        f1 = BloomFilter.new(4, 1)
        f2 = BloomFilter.new(4, 2)
        expect_raises(ArgumentError, "Cannot unite filters with different number of hash functions") do
          f1 | f2
        end
      end
    end

    context "filters match" do
      it "returns an union of two filters" do
        f1 = BloomFilter.new(32, 3)
        f1.insert("Esperanto")

        f2 = BloomFilter.new(32, 3)
        f2.insert("toki pona")

        f3 = f1 | f2
        f3.has?("Esperanto").should eq true
        f3.has?("toki pona").should eq true
      end
    end
  end

  describe "#&" do
    context "when filters have different size" do
      it "raises ArgumentError" do
        f1 = BloomFilter.new(4, 1)
        f2 = BloomFilter.new(8, 1)
        expect_raises(ArgumentError, "Cannot unite filters of different size") do
          f1 & f2
        end
      end
    end

    context "when filters have different number of hash functions" do
      it "raises ArgumentError" do
        f1 = BloomFilter.new(4, 1)
        f2 = BloomFilter.new(4, 2)
        expect_raises(ArgumentError, "Cannot unite filters with different number of hash functions") do
          f1 & f2
        end
      end
    end

    context "filters match" do
      it "returns an intersection of two filters" do
        f1 = BloomFilter.new(32, 3)
        f1.insert("Esperanto")
        f1.insert("Spanish")

        f2 = BloomFilter.new(32, 3)
        f2.insert("Esperanto")
        f2.insert("English")

        f3 = f1 & f2
        f3.has?("Esperanto").should eq true
        f3.has?("Spanish").should eq false
        f3.has?("English").should eq false
      end
    end
  end
end
