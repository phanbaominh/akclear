class ClearImage
  module TmpFileStorable
    def current_tmp_file
      Thread.current[:clear_image_tmp_file]
    end

    def create_tmp_file
      delete_tmp_file
      Thread.current[:clear_image_tmp_file] = Tempfile.create(['clear_image_extracting', '.png'])
    end

    def delete_tmp_file
      File.delete(current_tmp_file) if current_tmp_file && File.exist?(current_tmp_file.path)
    end

    def tmp_file_path
      current_tmp_file.path
    end
  end
end
