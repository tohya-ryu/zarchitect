module FileManager

  FROM = "_files" # dir where raw files reside
  TO   = "_html/files"

  def self.run
    # iterate FROM 
    Dir[ File.join(FROM, '**', '*') ].reject do |fullpath|
      path = fullpath[(FROM.length)..-1]
      realpath = File.join(TO, path) # path of new dir/symlink
      
      # dir handling / create copies in TO
      Util.mkdir(realpath) if File.directory?(fullpath)
      next if File.directory?(fullpath)
      # file handling
      # create symlink in _html/files to physical files _files
      unless File.symlink?(realpath)
        rrealpath = File.join(Dir.getwd, fullpath)
        symlink(rrealpath, realpath)
      end
      # handle file types embedded in posts
      if Image.is_valid?(fullpath)
        GPI.print "processing #{fullpath} as image file",
          GPI::CLU.check_option('v')
        ImageSet.new(path, fullpath, realpath)
      elsif Audio.is_valid?(fullpath)
        GPI.print "processing #{fullpath} as audio file",
          GPI::CLU.check_option('v')
      elsif Video.is_valid?(fullpath)
        GPI.print "processing #{fullpath} as video file",
          GPI::CLU.check_option('v')
      else
        GPI.print "processing #{fullpath} as any file",
          GPI::CLU.check_option('v')
      end

    end
  end

  def self.symlink(from, to)
    GPI.print "creating symlink #{to} ~> #{from}", 
      GPI::CLU.check_option('v')
    File.symlink(from, to)
    GPI.print "created symlink #{to} ~> #{from}",
      GPI::CLU.check_option('v')
  end

  def self.clean
    # remove all files in _html/files
  end

end

class FileObject
end
