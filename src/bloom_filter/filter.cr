module BloomFilter
  class Filter
    getter :hash_num, :bitsize, :bytesize

    SEED_A = 0xdeadbeef_u32
    SEED_B = 0x71fefeed_u32

    SALT_A = 0xb8b34b2d_u32
    SALT_B = 0x52c6a2d9_u32

    def initialize(bytesize, hash_num)
      @bytesize = bytesize
      @bitsize =  bytesize * 8
      @hash_num = hash_num.to_u8

      @bitmap = Array(UInt8).new(bytesize, 0_u8)
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
      self
    end

    def insert(str : String)
      each_probe(str) do |index|
        set(index)
      end
    end

    # Verifies, whether the filter contains given item.
    def has?(str : String) : Bool
      each_probe(str) do |index|
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

    @[AlwaysInline]
    private def set(index : UInt32)
      item_index = index / 8
      bit_index = index % 8
      @bitmap[item_index] = @bitmap[item_index] | (1 << bit_index)
    end

    @[AlwaysInline]
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

    @[AlwaysInline]
    private def each_probe(str : String)
      ha, hb = two_hash(str)
      pos = ha % (@bitsize - 1)       # @bitsize - 1 is always odd
      delta = 1 + hb % (@bitsize - 3) # @bitsize - 3 is also odd
      @hash_num.times do
        yield pos
        pos += delta
        pos -= @bitsize if pos >= @bitsize
        delta += 1
        delta = 1 if delta == @bitsize - 1
      end
    end

    # Hash function.
    @[AlwaysInline]
    private def two_hash(str : String) : Tuple(UInt32, UInt32)
      ha = SEED_A
      hb = SEED_B
      str.each_byte do |byte|
        ha = (hswap(ha) ^ byte) * SALT_A
        hb = (hswap(hb) ^ byte) * SALT_B
      end
      ha = hswap(ha) * SALT_A
      hb = hswap(hb) * SALT_B
      ha ^= ha >> 16
      hb ^= hb >> 16
      {ha, hb}
    end

    @[AlwaysInline]
    private def hswap(i : UInt32)
      i = (i << 16) | (i >> 16)
    end
  end
end
