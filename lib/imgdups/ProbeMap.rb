require 'imgdups/core/logger'
require 'imgdups/core/utils'
require 'time'
require 'FileUtils'

# ==============================================================================
#
class ProbeMap

  include FileUtils, LogAware

  attr_reader :today

  def initialize()
    @image_map = Hash.new
    @today = Date.today()
  end

  def add(label, image_path)
    # find container for the image
    images = @image_map[label]
    if images == nil
      images = Array.new()
      @image_map[label] = images
    end
    images.push(image_path)
  end

  def organize(output_location, check_duplicates = false)

    logger = TreeLogger.new(nil)

    logger.debug("Organizing output result at #{output_location}.")

    # validate output destinations
    touch_directory(output_location)

    total = 0
    @image_map.each {| label, images |
      total = total + images.size()
      logger.debug("Image Label #{label} has #{images.size()} photos.")
    }
    logger.debug("#{total} photos processed.")

    @image_map.each {| label, images |

      logger.debug("Processing files with label #{label}.")

      # branch out the logger
      branch = logger.branch()
      if check_duplicates && images.length() > 1
        branch.debug("#{label} has #{images.size()} possible photos.")

        images.each(){|image_path|
          # Check for duplication
          if duplicate?(image_path, images)
            # add this image to container
            images.delete(image_path)
          end
        }
        branch.debug("#{images.size()} left after possible duplicates removed.")
      end

      outloc = "#{output_location}/#{label}"
      logger.debug("Copy #{images.size()} files to destinations at #{outloc}")
      touch_directory(outloc)

      copy(images, outloc)
    }
  end
end
