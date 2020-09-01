module FileManager

  @img = Array.new
  @audio = Array.new
  @video = Array.new
  @misc  = Array.new

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
      # handle file types embedded in posts
      if Image.is_valid?(fullpath)
        GPI.print "processing #{fullpath} as image file",
          GPI::CLU.check_option('v')
        @img.push ImageSet.new(path, fullpath, realpath)
      elsif Audio.is_valid?(fullpath)
        GPI.print "processing #{fullpath} as audio file",
          GPI::CLU.check_option('v')
        @audio.push Audio.new(fullpath)
      elsif Video.is_valid?(fullpath)
        GPI.print "processing #{fullpath} as video file",
          GPI::CLU.check_option('v')
        @video.push Video.new(fullpath)
      else
        GPI.print "processing #{fullpath} as any file",
          GPI::CLU.check_option('v')
        @misc.push MiscFile.new(fullpath)
      end
      # create symlink in _html/files to physical files _files (if process did
      # not abort)
      unless File.symlink?(realpath)
        rrealpath = File.join(Dir.getwd, fullpath)
        symlink(rrealpath, realpath)
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
    %x{rm -r _html/files/*} 
  end

end
