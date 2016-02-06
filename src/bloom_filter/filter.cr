module BloomFilter
  class Filter
    INITIAL_SEED = 13

    getter :hash_num, :bitsize

    # n - the number of expected elements to be inserted
    # p - desired false positive probability
    # m - bitsize of the filter
    # k - number of hash functions
    def self.new_optimal(n, p)
      m = - (n * Math.log(p)) / Math.log(2)**2
      k = (m/n) * Math.log(2)

      bytesize = (m / 8).ceil.to_i
      k = k.round.to_i

      new(bytesize, k)
    end

    def self.load_file(file_path)
      File.open(file_path, "r") { |fd| load(fd) }
    end

    def self.load(io : IO)
      hash_num = io.read_byte
      filter = self.allocate
      filter.hash_num = hash_num as UInt8

      filter.bitmap = Array(UInt8).new

      bytesize = 0_u32
      while byte = io.read_byte
        filter.bitmap << byte.to_u8
        bytesize += 1
      end

      filter.bytesize = bytesize
      filter.bitsize = bytesize * 8
      filter.seeds = [] of UInt32
      filter.setup_seeds

      filter
    end


    property :hash_num, :bytesize, :bitsize, :bitmap, :seeds


    def initialize(bytesize, hash_num)
      @bytesize = bytesize
      @bitsize =  bytesize * 8
      @hash_num = hash_num.to_u8

      @bitmap = Array(UInt8).new(bytesize, 0_u8)
      @seeds = [] of UInt32

      setup_seeds
    end

    def setup_seeds
      random = Random.new(INITIAL_SEED)
      hash_num.times { @seeds << random.next_u32 }
    end

    # TODO: rename to +insert+ ?
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

    def bytesize
      @bitsize / 8
    end

    def dump(io : IO)
      io.write_byte(@hash_num)
      @bitmap.each do |byte|
        io.write_byte(byte)
      end
      io
    end

    def dump_file(file_name)
      File.open(file_name, "w") do |file|
        dump(file)
      end
    end

    def visualize
      pairs = [] of String
      four_bytes = @bitmap.map { |uint32| visualize_uint32(uint32) }
      four_bytes.each_slice(2) do |pair|
        pairs << pair.join(" ")
      end
      pairs.join("\n")
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
