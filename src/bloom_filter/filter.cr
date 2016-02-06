module BloomFilter
  class Filter
    INITIAL_SEED = 13

    getter :hash_count, :memory, :bitsize

    def self.new_optimal(n, p)
      m = - (n * Math.log(p)) / Math.log(2)**2
      k = (m/n) * Math.log(2)

      m = m.round.to_i
      k = k.round.to_i

      size = m.round / 32 + 1
      new(m, k)
    end

    def initialize(size, @hash_count)
      @bitsize = size * 32
      @memory = Array(UInt32).new(size, 0_u32)

      @seeds = [] of UInt32

      # Define seeds
      random = Random.new(INITIAL_SEED)
      @hash_count.times { @seeds << random.next_u32 }
    end

    def add(str : String)
      @seeds.each do |seed|
        index = djb2(str, seed) % @bitsize
        set(index)
      end
    end

    def has?(str : String) : Bool
      @seeds.each do |seed|
        index = djb2(str, seed) % @bitsize
        return false unless set?(index)
      end
      true
    end

    private def set(index : UInt32)
      item_index = index / 32
      bit_index = index % 32
      @memory[item_index] = @memory[item_index] | (1 << bit_index)
    end

    private def set?(index : UInt32) : Bool
      item_index = index / 32
      bit_index = index % 32
      @memory[item_index] & (1 << bit_index) != 0
    end

    def visualize
      pairs = [] of String
      four_bytes = @memory.map { |uint32| visualize_uint32(uint32) }
      four_bytes.each_slice(4) do |pair|
        pairs << pair.join(" ")
      end
      pairs.join("\n")
    end

    private def visualize_uint32(num : UInt32) : String
      binary = num.to_s(2)
      while binary.size < 32
        binary = "0" + binary
      end
      binary.gsub("0", "░").gsub("1", "▓")
    end

    # Hash function.
    # For more details see: http://www.cse.yorku.ca/~oz/hash.html
    private def djb2(str : String, seed : UInt32) : UInt32
      hash = seed
      str.each_byte do |byte|
        hash = (hash << 5) + hash + byte
      end
      hash
    end

    #def sdbm(str : String, seed : UInt32) : UInt32
    #  hash = seed
    #  str.each_byte do |byte|
    #    hash = (hash << 6) + (hash << 16) - hash + byte
    #  end
    #  hash
    #end
  end
end
