require 'imgdups/core/utils'

#===============================================================================
#
class ImageDataDirectory

  # Utilities Functions
  include BinaryUtils, ExifData, LogAware

  attr_reader :ifds

  def initialize(data, logger)
    @ifds = Hash.new()
    @ifds[0] = []
    @logger = logger

    ifd_counts = 0;
    # First Eight byte of data is header
    @header = Header.new(data[0, 8])
    parse_ifd(data, @header.start_offset,ifd_counts, @ifds)

  end

  private def parse_ifd(data, offset, ifd_counts, ifds)
    endian = @header.endian

    while offset != 0x00
      entry_count = endian.to_int_16(data[offset, 2])

      offset = offset + 2
      entry_count.times do |n|
        bytes = data[offset, 12]
        entry = Entry.new(bytes,endian)
        # Exif SubIFD
        if(entry.tag_number == 0x8769)
          tag_size = endian.to_int_32(entry.value)
          @logger.debug("Exif SubIFD found with size #{tag_size}")
          # add new IFD
          ifd_counts = ifd_counts + 1
          ifds[ifd_counts] = []
          parse_ifd(data, tag_size, ifd_counts, ifds)
        else
          # Read bytes for this
          entry.read_data(data)
          ifds[ifd_counts].push(entry)
        end

        if EXIF_TAGS[entry.tag_number] == nil
          @logger.debug( "Entry is not valid : #{entry.tag_number}")
        end

        offset = offset + 12
      end

      next_ifd_offset = endian.to_int_16(data[offset, 4])
      offset = next_ifd_offset
      #create new IFD container
      ifd_counts = ifd_counts + 1
      ifds[ifd_counts] = []
    end
  end
end

#==============================================================================
#
class Header

  # Utilities Functions
  include BinaryUtils

  attr_reader :endian, :start_offset

  def initialize(bytes)
    # First two byte defines endianness if data (order of the bytes)
    endianness = {'II' => 'Intel', 'MM' => 'Motorola'}

    endianness_marker = bytes[0, 2]
    if(endianness_marker == "II")
      @endian = IntelEndian.new()
    else
      @endian = MotorolaEndian.new()
    end

    # next two bytes should be either II=> 0x2A00 or MM=> 0x2A00.
    tiff_version = @endian.to_int_16(bytes[2,2])
    if tiff_version != 0x002A
      raise "TIFF header data is not validated."
    end

    # Next 4 bytes are offset of the IFD(Image File Directory)
    @start_offset = @endian.to_int_32(bytes[4, 4])
  end

  def to_s()
    return "Header => endian :: #{@endian}, start_offset :: #{@start_offset}"
  end
end

#==============================================================================
#
class Entry
  # Utilities Functions
  include BinaryUtils, ExifData

  attr_reader :tag_number, :data_type, :component_count, :value, :data_bytes
  attr_writer :data_bytes

  def initialize(bytes, endian)

    @endian = endian

    # Tag number
    offset =  0
    @tag_number = endian.to_int_16(bytes[offset, 2])

    # offset
    offset =  offset + 2
    @data_type = endian.to_int_16(bytes[offset, 2])

    #component_count in the entries
    offset =  offset + 2
    @component_count = endian.to_int_32(bytes[offset, 4])

    offset =  offset + 4
    @value = bytes[offset, 4]
  end

  public def to_s()
    return "Entry =>  #{EXIF_TAGS[@tag_number]}(0x#{@tag_number.to_s(16)}), #{@data_type}, #{@component_count}, '#{@value}'"
  end

  public def read_data(data)

    data_length = (@component_count * ByteComponantMap[@data_type])
    bytes = []
    if(data_length <= 4)
      bytes = @value
    else
      data_offset = @endian.to_int_32(@value)
      bytes = data[data_offset , data_length]
    end
    if(@data_type == 1)
      @data_bytes = @endian.unsigned_byte(bytes)
    elsif (@data_type == 2)
      @data_bytes = @endian.to_string(bytes)
    elsif (@data_type == 3)
      @data_bytes =  @endian.unsigned_short(bytes)
    elsif (@data_type == 4)
      @data_bytes =  @endian.unsigned_long(bytes)
    elsif (@data_type == 5)
      @data_bytes =  @endian.unsigned_rational(bytes)
    elsif (@data_type == 6)
      @data_bytes =  @endian.signed_byte(bytes)
    elsif (@data_type == 7)
      @data_bytes =  @endian.signed_short(bytes)
    elsif (@data_type == 8)
      @data_bytes =  @endian.signed_short(bytes)
    elsif (@data_type == 9)
      @data_bytes =  @endian.signed_long(bytes)
    elsif (@data_type == 10)
      @data_bytes =  @endian.signed_rational(bytes)
    elsif (@data_type == 11)
      @data_bytes =  @endian.single_float(bytes)
    elsif (@data_type == 12)
      @data_bytes =  @endian.double_float(bytes)
    end
  end
end
#==============================================================================
#
