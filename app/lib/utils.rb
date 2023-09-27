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

    def average(array)
      return 0 if array.empty?

      array.sum / array.size.to_f
    end
  end
end
