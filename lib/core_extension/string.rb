module CoreExtension
  module String
    def from_hex
      self.to_i(16)
    end

    def to_hex
      Ethereum::Encoder.new.encode_static_bytes(self)
    end

    def hex_to_ascii
      self.scan(/../).map { |x| x.hex.chr }.join.strip
    end
  end
end