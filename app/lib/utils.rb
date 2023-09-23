module Utils
  class << self
    def generate_tmp_path(prefix:, suffix: nil)
      file = Tempfile.new([prefix, suffix].compact)
      path = file.path
      file.close
      path
    end

    def within_ratio?(a, b, ratio)

      a * (1 + ratio) >= b && a <= b * (1 + ratio)
    end
  end
end
