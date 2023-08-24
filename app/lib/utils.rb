module Utils
  class << self
    def generate_tmp_path(prefix:, suffix: nil)
      file = Tempfile.new([prefix, suffix].compact)
      path = file.path
      file.close
      path
    end
  end
end
