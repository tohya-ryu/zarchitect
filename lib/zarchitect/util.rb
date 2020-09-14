module Util

  def self.mkdir(path)
    a = path.split("/")
    i = 0
    a.each do |s|
      if i > 0
      else
        Util.mkdir2(s)
      end
      i += 1
    end

  end
  
  # path to data files located in installation directory
  def self.path_to_data
    File.join(__dir__, "../../data")
  end

  # PRIVATE

  def self.mkdir2(path)
    npath = File.join(Dir.getwd, path)
    GPI.print "Checking for directory #{npath}", GPI::CLU.check_option('v')
    unless Dir.exist?(npath)
      GPI.print "Missing directory #{npath}", GPI::CLU.check_option('v')
      GPI.print "Creating directory #{npath}", GPI::CLU.check_option('v')
      Dir.mkdir(npath)
      GPI.print "Created directory #{npath}", GPI::CLU.check_option('v')
    end
  end

end
