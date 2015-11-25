require 'pathname'
require 'set'
require 'time'
require 'imgdups/ProbeMap'
require 'imgdups/io/ImageStream'
require 'imgdups/io/Model'
require 'imgdups/core/logger'
require 'imgdups/core/utils'
require 'imgdups/core/file'
require 'imgdups/tools/imaging'

#=========================+=====================================================
#
class DuplicateImageChecker

  # Investigates image files for possible duplicates.

  include LogAware, FileUtils, Watch

  def initialize(root_directory, output_location, log_file= './logs')
    @report = ProbeMap.new();
    @root_directory = root_directory
    @output_location = output_location
    @logger = TreeLogger.new(log_file)

    touch_directory(@output_location)
  end

  public def investigate()

    watch = Stopwatch.new()

    @logger.debug("Duplicate image discovery starts for  : #{@root_directory}")

    files = list_files(@root_directory, recursive= true, file_type="JPG")

    @logger.info("#{files.size} images are loaded from #{@root_directory}")

    for filename in files do
      #filename = 'E:/OneDrive/Picture//Camera/IMG_20150704_073417.jpg'
      begin
        @logger.info("Processing file : #{filename}")

        File.open(filename){|file|
          imaging = Imaging.new(file)

          camara_model = imaging.camara_model()
          if blank?(camara_model) == true
            camara_model = "Unknown"
          end
          @report.add(camara_model, file)
        }

      rescue => err
        puts( "Exception in processing file #{filename}. Error :  #{err}")
        puts(err.backtrace)
        @report.add("ErrorInReading", File.new(filename))
        break;
      end
      #break
    end

    @report.organize(@output_location, check_duplicates = false)

    watch.elapsed()

  end

  private def print_metadata(filename)
    File.open(filename){|file|
      stream = ImageStream.new(file, @logger.branch())
      stream.print_metadata()
    }
  end

  private def process_file(filename)
    File.open(filename){|file|
      stream = ImageStream.new(file, @logger.branch())

      capture_date = stream.capture_date()

      if(capture_date == nil)
        raise "Unable to read capture_date from file #{filename}"
      end

      @report.add(capture_date, File.path(file))
    }
  end

  private def blank?(str)
    blank = false

    if str == nil
      blank = true
    else
      len = str.length();
      if len == 0
        blank = true
      else
        len = str.strip().length()
        if len == 0
          blank = true
        end
      end
    end
  end
end
