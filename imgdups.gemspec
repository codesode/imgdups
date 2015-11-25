Gem::Specification.new do |s|
  s.name        = 'imgdups'
  s.version     = '1.0.0'
  s.summary     = "imgdups!"
  s.licenses    = ['Apache']
  s.description = "Remove duplicates from photo collections!"
  s.authors     = ["Vijay Shanker Dubey"]
  s.email       = 'vijaydshanker@codesode.com'
  s.homepage    = 'http://imgdups.codesode.com'
  s.files       = ['lib/imgdups.rb',
                  "lib/imgdups/Investigator.rb",
                  'lib/imgdups/ProbeMap.rb',
                  'lib/imgdups/core/logger.rb',
                  'lib/imgdups/core/utils.rb',
                  'lib/imgdups/core/file.rb',
                  'lib/imgdups/io/ImageStream.rb',
                  'lib/imgdups/io/Model.rb',
                  'lib/imgdups/tools/imaging.rb']
end
