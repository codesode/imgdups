require 'imgdups/core/logger'
require 'imgdups/io/Model'
require 'imgdups/core/logger'
require 'imgdups/core/utils'
require 'time'

#==============================================================================
#
class Imaging

  include LogAware, ExifData

  public def initialize(file)
    @logger = TreeLogger.new(ARGV[3])
    @stream = ImageStream.new(file, @logger.branch())
  end

  private def data_by_tag(tag_number)

    ifds = @stream.ifds()

    data = nil
    ifds.each {| key, value |
      value.each { |entry|
        if entry.tag_number == tag_number
          data = entry.data_bytes()
          break
        end
      }
      break if (data != nil)
    }

    return data
  end

  public def camara_model()

    make = data_by_tag(0x10F)
    model = data_by_tag(0x110)

    return "#{make} #{model}"
  end

  public def print_metadata()
    puts("Image File Metadata")
    @stream.ifds().each {| key, value |
      value.each { |entry|
        data = ""
        bytes = entry.data_bytes()
        if( bytes !=nil)
          data = bytes.to_s()
        end
        puts "\t#{EXIF_TAGS[entry.tag_number]} => '#{data}'"
      }
    }
  end

  public def capture_date()

    date = data_by_tag(0x132)

    if date == nil
      date = data_by_tag(0x132)
    end

    return date
  end
end
