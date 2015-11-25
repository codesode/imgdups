require 'imgdups/core/logger'
require 'imgdups/io/Model'
require 'imgdups/core/logger'
require 'imgdups/core/utils'
require 'time'

#==============================================================================
#
class ImageStream

  include LogAware, BinaryUtils, ExifData

  attr_reader :ifds

  public def initialize(file, logger)
    @stream = file
    @endian = MotorolaEndian.new()
    @logger = logger

    #parse image metadata
    @ifds = parse_image()
  end

  private def read(size = 1)
    return @stream.read(size)
  end

  private def next_byte()
    return read(1).ord()
  end

  private def parse_image()
    # validate image magic number
    validate()

    # after this validation, next byte sould be 0xE1.
    byte_value = next_byte()

    #metadata container
    ifds = Hash.new()

    if (byte_value == 0xE1)
      # length = ((next two bytes) - 2)  as ( size includes length bytes)
      data_size = @endian.to_int_16(read(2))
      data = read( data_size - 2)
      @logger.debug("Image file has Exif metadata of #{data_size} bytes")

      # parse data
      imd = ExifImage.new()
      imd.logger = @logger
      ifds = ifds.merge(imd.parse(data))
    elsif((byte_value == 0xE0))
      data_size = @endian.to_int_16(read(2))
      data = read( data_size -2)
      @logger.debug("Image file has JFIF metadata of #{data_size} bytes")
      imd = JFIFImage.new()
      imd.logger = @logger
      ifds = ifds.merge(imd.parse(data))

      # Further should be parsed as 0xE1.
      byte_value = read(2);
      if (byte_value[1].ord() == 0x00E1)
        # length = ((next two bytes) - 2)  as ( size includes length bytes)
        data_size = @endian.to_int_16(read(2))
        exif_stream = read( data_size -2)
        @logger.debug("Image file has Exif metadata of #{data_size} bytes")
        imd = ExifImage.new()
        imd.logger = @logger
        ifds = ifds.merge(imd.parse(exif_stream))
      end
    end

    return ifds
  end

  private def validate()
    # The first three bytes should be FF, SOI (Start of Image => 0xD8), FF
    first_byte = next_byte()
    second_byte = next_byte()
    third_byte = next_byte()

    if ((first_byte != 0xFF) and
      (second_byte != 0xD8) and
      (third_byte != 0xFF))
      raise "Image file does not have valid header."
    end
  end
end

#==============================================================================
#
class ImageMetadata

  # Logging System
  include LogAware, BinaryUtils

  attr_writer :logger

  protected def validate(data)
    # metadata type : Next four bytes should be indentified as JFIF
    identifier = data[0,4]
    if (identifier != @header)
      raise "Image file does not have valid #{@header} Identifier"
    end

    # next 2 bytes of 0x00
    if (data[4].ord() != 0x00 && data[5].ord() != 0x00)
      raise "Image file does not have valid #{@header} Identifier marker"
    end
  end

end

#==============================================================================
#
class JFIFImage < ImageMetadata

  public def initialize()
    @header = "JFIF"
  end

  public def parse(data)

    ifds = Hash.new()

    validate(data[0,6])

    version = "#{data[6].ord()}.#{data[7].ord()}"
    density_unit = data[8].ord()
    xdensity_unit = IntelEndian.new().to_int_16(data[9,2])
    ydensity_unit = IntelEndian.new().to_int_16(data[11,2])
    xthumbnail_unit = data[12].ord()
    ythumbnail_unit = data[13].ord()
    thumbnail_bytes_size = xthumbnail_unit * ythumbnail_unit * 3
    thumbnail_data = []
    if(thumbnail_bytes_size != 0)
      thumbnail_data = data[14, thumbnail_bytes_size]
    end

    @logger.debug("JIFF Data : version : #{version}, density unit : #{density_unit}, Xdensity : #{xdensity_unit} , Ydensity :#{ydensity_unit} , Xthumbnail : #{xthumbnail_unit} , Ythumbnail : #{ythumbnail_unit} ,Thumbnail Data Size : #{thumbnail_data}")

    return ifds

  end

end

#===============================================================================
#
class ExifImage < ImageMetadata

  public def initialize()
    @header = "Exif"
  end

  public def parse(data)

    validate(data[0,6])

    tiff_data = data[6, data.length() - 6 ]
    data_directory = ImageDataDirectory.new(tiff_data, @logger)
    ifds = data_directory.ifds()

    return ifds
  end
end
