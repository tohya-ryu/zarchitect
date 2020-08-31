module Util

  def self.mkdir(path)
    npath = File.join(Dir.getwd, path)
    unless Dir.exist?(npath)
      GPI.print "Missing directory #{npath}", GPI::CLU.check_option('v')
      GPI.print "Creating directory #{npath}", GPI::CLU.check_option('v')
      Dir.mkdir(npath)
      GPI.print "Created directory #{npath}", GPI::CLU.check_option('v')
    end
  end

  def self.path_to_data
    File.join(__dir__, "../../data")
  end

end
