require "../spec_helper"

#describe BloomFilter::Filter do
#  describe ".new_optimal" do
#    it "creates filter with optimal parameters" do
#      filter = BloomFilter::Filter.new_optimal(1_000_000, 0.001)
#      filter.should be_a BloomFilter::Filter
#    end
#  end

#  describe ".new" do
#    it "creates filter with given bytesize hash functions" do
#      filter = BloomFilter::Filter.new(64, 3)
#      filter.bytesize.should eq 64
#      filter.bitsize.should eq 64*8
#      filter.hash_num.should eq 3
#    end

#    context "when bytesize is not an even 4" do
#      it "calculates minimal bytesize even 4, that is greater than the given one " do
#        filter = BloomFilter::Filter.new(5, 3)
#        filter.bytesize.should eq 8
#        filter.bitsize.should eq 8*8
#      end
#    end
#  end

#  describe "#add" do
#    it "adds element to the filter" do
#      filter = BloomFilter::Filter.new(100, 5)
#      filter.add("abc")
#    end
#  end

#  describe "#has?" do
#    context "filter has items" do
#      it "returns true if item is present" do
#        filter = BloomFilter::Filter.new(256, 4)
#        filter.add("test")

#        filter.has?("test").should eq true
#        filter.has?("Test").should eq false
#        filter.has?("TEST").should eq false
#      end
#    end
#  end
#end
