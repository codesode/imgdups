#==============================================================================
#
module BinaryUtils

  class Endianness
    def do_unpack(bytes, directive)
      return bytes.unpack(directive).first
    end

    def unsigned_byte(bytes)
      return do_unpack(bytes, 'C')
    end

    def signed_byte(bytes)
      return do_unpack(bytes, 'c')
    end

    def to_string(bytes)
      return do_unpack(bytes, 'A*')
    end

  end

  class IntelEndian < Endianness

    def to_int_16(bytes)
      return do_unpack(bytes, 'v')
    end

    def to_int_32(bytes)
      return do_unpack(bytes, 'V')
    end

    def unsigned_short(bytes)
      return do_unpack(bytes, 'S_<')
    end

    def signed_short(bytes)
      return do_unpack(bytes, 's_<')
    end

    def unsigned_rational(bytes)
      numerator = unsigned_long(bytes[0, 4])
      denumerator = unsigned_long(bytes[4, 4])
      return "#{numerator}/#{denumerator}"
    end

    def signed_rational(bytes)
      numerator = signed_long(bytes[0, 4])
      denumerator = signed_long(bytes[4, 4])
      return "#{numerator}/#{denumerator}"
    end

    def unsigned_long(bytes)
      return do_unpack(bytes, 'L_<')
    end

    def signed_long(bytes)
      return do_unpack(bytes, 'l_<')
    end
  end

  class MotorolaEndian <Endianness

    def to_int_16(bytes)
      return do_unpack(bytes, 'n')
    end

    def to_int_32(bytes)
      return do_unpack(bytes, 'N')
    end

    def unsigned_short(bytes)
      return do_unpack(bytes, 'S>')
    end

    def signed_short(bytes)
      return do_unpack(bytes, 's_>')
    end

    def unsigned_rational(bytes)
      numerator = unsigned_long(bytes[0, 4])
      denumerator = unsigned_long(bytes[4, 4])
      return "#{numerator}/#{denumerator}"
    end

    def signed_rational(bytes)
      numerator = signed_long(bytes[0, 4])
      denumerator = signed_long(bytes[4, 4])
      return "#{numerator}/#{denumerator}"
    end

    def unsigned_long(bytes)
      return do_unpack(bytes, 'L_>')
    end

    def signed_long(bytes)
      return do_unpack(bytes, 'l_>')
    end

  end

  def to_hex(bytes)
      val = '0x'
      bytes.each_char { |chr|  val = val + chr.ord().to_s(16)}
      return val
    end
end

module ExifData
  EXIF_TAGS = {
    0x100 =>	"ImageWidth",
    0x101 =>	"ImageLength",

    0x102 =>	"BitsPerSample",
    0x103 =>	"Compression",
    0x106 =>	"PhotometricInterpretation",
    0x10A =>	"FillOrder",
    0x10D =>	"DocumentName",
    0x10E =>	"ImageDescription",
    0x10F =>	"Make",
    0x110 =>	"Model",
    0x111 =>	"StripOffsets",
    0x112 =>	"Orientation",
    0x115 =>	"SamplesPerPixel",
    0x116 =>	"RowsPerStrip",
    0x117 =>	"StripByteCounts",
    0x11A =>	"XResolution",
    0x11B =>	"YResolution",
    0x11C =>	"PlanarConfiguration",
    0x128 =>	"ResolutionUnit",
    0x12D =>	"TransferFunction",
    0x131 =>	"Software",
    0x132 =>	"DateTime",
    0x13B =>	"Artist",
    0x13E =>	"WhitePoint",
    0x13F =>	"PrimaryChromaticities",
    0x156 =>	"TransferRange",
    0x200 =>	"JPEGProc",
    0x201 =>	"JPEGInterchangeFormat",
    0x202 =>	"JPEGInterchangeFormatLength",
    0x211 =>	"YCbCrCoefficients",
    0x212 =>	"YCbCrSubSampling",
    0x213 =>	"YCbCrPositioning",
    0x214 =>	"ReferenceBlackWhite",
    0x828F =>	"BatteryLevel",
    0x8298 =>	"Copyright",
    0x829A =>	"ExposureTime",
    0x829D =>	"FNumber",
    0x83BB =>	"IPTC/NAA",
    0x8769 =>	"ExifIFDPointer",
    0x8773 =>	"InterColorProfile",
    0x8822 =>	"ExposureProgram",
    0x8824 =>	"SpectralSensitivity",
    0x8825 =>	"GPSInfoIFDPointer",
    0x8827 =>	"ISOSpeedRatings",
    0x8828 =>	"OECF",
    0x9000 =>	"ExifVersion",
    0x9003 =>	"DateTimeOriginal",
    0x9004 =>	"DateTimeDigitized",
    0x9101 =>	"ComponentsConfiguration",
    0x9102 =>	"CompressedBitsPerPixel",
    0x9201 =>	"ShutterSpeedValue",
    0x9202 =>	"ApertureValue",
    0x9203 =>	"BrightnessValue",
    0x9204 =>	"ExposureBiasValue",
    0x9205 =>	"MaxApertureValue",
    0x9206 =>	"SubjectDistance",
    0x9207 =>	"MeteringMode",
    0x9208 =>	"LightSource",
    0x9209 =>	"Flash",
    0x920A =>	"FocalLength",
    0x9214 =>	"SubjectArea",
    0x927C =>	"MakerNote",
    0x9286 =>	"UserComment",
    0x9290 =>	"SubSecTime",
    0x9291 =>	"SubSecTimeOriginal",
    0x9292 =>	"SubSecTimeDigitized",
    0xA000 =>	"FlashPixVersion",
    0xA001 =>	"ColorSpace",
    0xA002 =>	"PixelXDimension",
    0xA003 =>	"PixelYDimension",
    0xA004 =>	"RelatedSoundFile",
    0xA005 =>	"InteroperabilityIFDPointer",
    0xA20B =>	"FlashEnergy",			# 0x920B in TIFF/EP
    0xA20C =>	"SpatialFrequencyResponse",	# 0x920C    -  -
    0xA20E =>	"FocalPlaneXResolution",	# 0x920E    -  -
    0xA20F =>	"FocalPlaneYResolution",	# 0x920F    -  -
    0xA210 =>	"FocalPlaneResolutionUnit",	# 0x9210    -  -
    0xA214 =>	"SubjectLocation",		# 0x9214    -  -
    0xA215 =>	"ExposureIndex",		# 0x9215    -  -
    0xA217 =>	"SensingMethod",		# 0x9217    -  -
    0xA300 =>	"FileSource",
    0xA301 =>	"SceneType",
    0xA302 => "CFAPattern",			# 0x828E in TIFF/EP
    0xA401 => "CustomRendered",
    0xA402 => "ExposureMode",
    0xA403 =>	"WhiteBalance",
    0xA404 =>	"DigitalZoomRatio",
    0xA405 =>	"FocalLengthIn35mmFilm",
    0xA406 =>	"SceneCaptureType",
    0xA407 =>	"GainControl",
    0xA408 =>	"Contrast",
    0xA409 =>	"Saturation",
    0xA40A =>	"Sharpness",
    0xA40B =>	"DeviceSettingDescription",
    0xA40C =>	"SubjectDistanceRange",
    0xA420 =>	"ImageUniqueID",
  }

  INTR_TAGS = {
    0x1 =>	"InteroperabilityIndex",
    0x2 =>	"InteroperabilityVersion",
    0x1000 =>	"RelatedImageFileFormat",
    0x1001 =>	"RelatedImageWidth",
    0x1002 =>	"RelatedImageLength",
  }

  GPS_TAGS = {
    0x0 =>	"GPSVersionID",
    0x1 =>	"GPSLatitudeRef",
    0x2 =>	"GPSLatitude",
    0x3 =>	"GPSLongitudeRef",
    0x4 =>	"GPSLongitude",
    0x5 =>	"GPSAltitudeRef",
    0x6 =>	"GPSAltitude",
    0x7 =>	"GPSTimeStamp",
    0x8 =>	"GPSSatellites",
    0x9 =>	"GPSStatus",
    0xA =>	"GPSMeasureMode",
    0xB =>	"GPSDOP",
    0xC =>	"GPSSpeedRef",
    0xD =>	"GPSSpeed",
    0xE =>	"GPSTrackRef",
    0xF =>	"GPSTrack",
    0x10 =>	"GPSImgDirectionRef",
    0x11 =>	"GPSImgDirection",
    0x12 =>	"GPSMapDatum",
    0x13 =>	"GPSDestLatitudeRef",
    0x14 =>	"GPSDestLatitude",
    0x15 =>	"GPSDestLongitudeRef",
    0x16 =>	"GPSDestLongitude",
    0x17 =>	"GPSDestBearingRef",
    0x18 =>	"GPSDestBearing",
    0x19 =>	"GPSDestDistanceRef",
    0x1A =>	"GPSDestDistance",
    0x1B =>	"GPSProcessingMethod",
    0x1C =>	"GPSAreaInformation",
    0x1D =>	"GPSDateStamp",
    0x1E =>	"GPSDifferential"
  }

  ByteComponantMap ={
    1 => 1,
    2 => 1,
    3 => 2,
    4 => 4,
    5 => 8,
    6 => 1,
    7 => 1,
    8 => 2,
    9 => 4,
    10 => 8,
    11 => 4,
    12 => 8,
  }
end

module Watch

  class Stopwatch

    def initialize()
      @start = Time.now
      puts "Started: #{@start.to_s()}"
    end

    def elapsed()
      now = Time.now
      elapsed = now - @start
      puts "Started: #{@start.to_s()}, Now: #{now.to_s()}, Elapsed time: #{elapsed.to_s} seconds"
      return elapsed.to_s
    end

  end

end
