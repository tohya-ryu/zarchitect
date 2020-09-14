module Util

  def self.mkdir(path)
    a = path.split("/")
    if a.count == 1
        Util.mkdir2(path)
    else
      i = 0
      p = ""
      a.each do |s|
        if i == 0
          p = s
          Util.mkdir2(p)
        else
          p = File.join(p, s)
          Util.mkdir2(p)
        end
        i += 1
      end
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
