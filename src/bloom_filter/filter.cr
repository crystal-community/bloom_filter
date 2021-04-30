module BloomFilter
  class Filter
    @bitsize : UInt32

    getter hash_num : UInt8
    getter bitsize : UInt32
    getter bitmap : Bytes

    def bytesize
      @bitmap.size
    end

    SEED_A = 0xdeadbeef_u32
    SEED_B = 0x71fefeed_u32

    MULT_A = 0xb8b34b2d_u32
    MULT_B = 0x52c6a2d9_u32

    def initialize(bytesize, hash_num, @bitmap = Bytes.new(bytesize.to_i32, 0_u8))
      @bitsize = (bytesize * 8).to_u32
      @hash_num = hash_num.to_u8
    end

    # I used to load filter from file (see BloomFilter.load).
    def initialize(io : IO)
      @hash_num = io.read_byte.as UInt8

      # TODO: Is it possible to read 4 byte chunks?
      size = IO::ByteFormat::BigEndian.decode(Int32, io)
      @bitmap = Bytes.new(size)
      io.read_fully(@bitmap).to_u32

      @bitsize = (size * 8).to_u32
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
      IO::ByteFormat::BigEndian.encode(@bitmap.size, io)
      # TODO: is it possible write 4 byte chunks?
      @bitmap.each { |byte| io.write_byte(byte) }
      io
    end

    def ==(another : Filter)
      self.bytesize == another.bytesize && @hash_num == another.hash_num && @bitmap == another.bitmap
    end

    # Get a union of two filters.
    def |(another : Filter) : Filter
      raise(ArgumentError.new("Cannot unite filters of different size")) unless another.bytesize == self.bytesize
      raise(ArgumentError.new("Cannot unite filters with different number of hash functions")) unless another.hash_num == @hash_num

      union_bitmap = Bytes.new(bytesize) do |index|
        @bitmap[index] | another.bitmap[index]
      end
      Filter.new(self.bytesize, @hash_num, union_bitmap)
    end

    # Get intersection of two filters.
    def &(another : Filter) : Filter
      raise(ArgumentError.new("Cannot unite filters of different size")) unless another.bytesize == self.bytesize
      raise(ArgumentError.new("Cannot unite filters with different number of hash functions")) unless another.hash_num == @hash_num

      intersection_bitmap = Bytes.new(bytesize) do |index|
        @bitmap[index] & another.bitmap[index]
      end
      Filter.new(self.bytesize, @hash_num, intersection_bitmap)
    end

    @[AlwaysInline]
    private def set(index : UInt32)
      item_index = index // 8
      bit_index = index % 8
      @bitmap[item_index] = @bitmap[item_index] | (1 << bit_index)
    end

    @[AlwaysInline]
    private def set?(index : UInt32) : Bool
      item_index = index // 8
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
      binary.gsub("0", "░").gsub("1", "█")
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
      u = str.to_unsafe
      (str.bytesize // 4).times do
        v = 0_u32
        4.times { |i| v |= u[i].to_u32 << (i*8) }
        ha = hswap(ha ^ v) &* MULT_A
        hb = (hswap(hb) ^ v) &* MULT_B
        u += 4
      end
      v = 0_u32
      (str.bytesize & 3).times { |i| v |= u[i].to_u32 << (i*8) }
      # use simple finalization relying on odd module (bitsize-1 and bitsize-3)
      ha ^= v + str.bytesize
      hb ^= v
      {ha, hb}
    end

    @[AlwaysInline]
    private def hswap(i : UInt32)
      i = (i << 16) | (i >> 16)
    end
  end
end
