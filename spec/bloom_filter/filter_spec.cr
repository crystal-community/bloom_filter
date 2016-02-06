require "../spec_helper"

describe BloomFilter::Filter do
  describe ".new_optimal" do
    it "creates filter with optimal parameters" do
      filter = BloomFilter::Filter.new_optimal(1_000_000, 0.001)
      filter.should be_a BloomFilter::Filter
    end
  end

  describe ".new" do
    it "creates filter of a given size with given number of hash functions" do
      filter = BloomFilter::Filter.new(10, 3)
    end

    describe "#add" do
      it "adds element to the filter" do
        filter = BloomFilter::Filter.new(100, 5)
        filter.add("abc")
      end
    end

    describe "#has?" do
      context "filter has items" do
        it "returns true if item is present" do
          filter = BloomFilter::Filter.new(256, 4)
          filter.add("test")

          filter.has?("test").should eq true
          filter.has?("Test").should eq false
          filter.has?("TEST").should eq false
        end
      end
    end
  end
end
