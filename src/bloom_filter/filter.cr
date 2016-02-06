module BloomFilter
  class Filter
    INITIAL_SEED = 13

    getter :hash_num, :bitsize, :bytesize

    def initialize(bytesize, hash_num)
      @bytesize = bytesize
      @bitsize =  bytesize * 8
      @hash_num = hash_num.to_u8

      @bitmap = Array(UInt8).new(bytesize, 0_u8)
      @seeds = [] of UInt32
      setup_seeds
    end

    # I used to load filter from file (see BloomFilter.load).
    protected def initialize_from_io(io : IO)
      hash_num = io.read_byte
      @hash_num = hash_num as UInt8

      @bitmap = Array(UInt8).new

      # TODO: Is it possible to read 4 byte chunks?
      @bytesize = 0_u32
      while byte = io.read_byte
        @bitmap << byte.to_u8
        @bytesize += 1
      end

      @bitsize = bytesize * 8
      @seeds = [] of UInt32
      setup_seeds
      self
    end

    def insert(str : String)
      @seeds.each do |seed|
        index = djb2_hash(str, seed) % @bitsize
        set(index)
      end
    end

    # Verifies, whether the filter contains given item.
    def has?(str : String) : Bool
      @seeds.each do |seed|
        index = djb2_hash(str, seed) % @bitsize
        return false unless set?(index)
      end
      true
    end

    # Saves bloom filter into binary file.
    def dump_file(file_path)
      File.open(file_path, "w") { |fd| dump(fd) }
    end

    def dump(io : IO)
      io.write_byte(@hash_num)
      # TODO: is it possible write 4 byte chunks?
      @bitmap.each { |byte| io.write_byte(byte) }
      io
    end

    protected def setup_seeds
      @seeds = [] of UInt32
      random = Random.new(INITIAL_SEED)
      hash_num.times { @seeds << random.next_u32 }
    end

    private def set(index : UInt32)
      item_index = index / 8
      bit_index = index % 8
      @bitmap[item_index] = @bitmap[item_index] | (1 << bit_index)
    end

    private def set?(index : UInt32) : Bool
      item_index = index / 8
      bit_index = index % 8
      @bitmap[item_index] & (1 << bit_index) != 0
    end

    # Convert bitmap into string representation of bitmap with highlighted bits.
    # Should be used only for debugging and fun:)
    def visualize
      pairs = [] of String
      four_bytes = @bitmap.map { |uint32| visualize_uint32(uint32) }
      four_bytes.each_slice(8) do |pair|
        pairs << pair.join(" ")
      end
      pairs.join("\n")
    end

    # Convert byte into 8 chars string, that highlights set bits.
    private def visualize_uint32(num : UInt8) : String
      binary = num.to_s(2)
      while binary.size < 8
        binary = "0" + binary
      end
      binary.gsub("0", "░").gsub("1", "▓")
    end

    # Hash function. Works fast and well.
    # For more details see: http://www.cse.yorku.ca/~oz/hash.html
    private def djb2_hash(str : String, seed : UInt32) : UInt32
      hash = seed
      str.each_byte do |byte|
        hash = (hash << 5) + hash + byte
      end
      hash
    end
  end
end
