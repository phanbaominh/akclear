class ClearImage
  module TmpFileStorable
    def tmp_file_path
      @tmp_file_path ||= Utils.generate_tmp_path(prefix: 'clear_image', suffix: '.png')
    end
  end
end
