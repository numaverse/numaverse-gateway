module CoreExtension
  module Numeric
    def to_hex
      "0x#{self.to_s(16)}"
    end

    def numa_to_nuwei
      self * 1000000000000000000
    end
  end
end