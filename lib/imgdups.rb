require 'imgdups/Investigator'

#===============================================================================
#
class ImageDups

	def self.run(source_directory, dest_directory, log_file)
	  di = DuplicateImageChecker.new(source_directory, dest_directory, log_file)
	  duplicates = di.investigate()
	end

end
