module Util

  def self.mkdir(path)
    unless Dir.exist?(path)
      GPI.print "Missing directory #{path}", GPI::CLU.check_option('v')
      GPI.print "Creating directory #{path}", GPI::CLU.check_option('v')
      Dir.mkdir(File.join(Dir.getwd, path))
      GPI.print "Created directory #{path}", GPI::CLU.check_option('v')
    end
  end

end
