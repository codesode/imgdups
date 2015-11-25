# ==============================================================================
#
module FileUtils

  def list_files(root_directory, recursive= true, file_type=".JPG")

    file_depth = ''

    if recursive
      file_depth = file_depth + '/**/*'
    else
      file_depth = file_depth + '/*/*'
    end

    # Walk through the file system and list all files of file_type
    host_dir = [root_directory, file_depth, file_type].join("")
    file_list = Dir.glob(host_dir)

    return file_list
  end

  def touch_directory(filepath)
    result = false

    if ! Dir.exist?(filepath)
      result = Dir.mkdir(filepath)
    end

    return result;
  end

  def duplicate?(image_path, possible_duplicates)
    source_bytes = File.binread(image_path).unpack('B*')
    duplicate = false
    for possible_duplicate in possible_duplicates do
        possible_duplicate_bytes = File.binread(possible_duplicate).unpack('B*')

        if(source_bytes == possible_duplicate_bytes)
          duplicate = true
        end
    end
    return duplicate
  end

  def copy(images, outloc)
    touch_directory(outloc)
    dup_counter = 100
    images.each { |image|
      dest_file = "#{outloc}/#{File.basename(image)}"
      # copy image to this dest_file
      if File.exist?(dest_file)
        dup_counter = dup_counter + 1
        dest_file = "#{outloc}/#{File.basename(image, '.*')} - #{dup_counter}#{File.extname(image)}"
        FileUtils.cp(image, dest_file)
      else
        FileUtils.cp(image, dest_file)
      end
    }
  end

end
