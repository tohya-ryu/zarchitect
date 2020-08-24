module FileManager

  FROM = "_files" # dir where raw files reside
  TO   = "_html/files"

  def self.run
    # iterate FROM 
    Dir[ File.join(FROM, '**', '*') ].reject do |fullpath|
      path = fullpath[(FROM.length)..-1]
      realpath = File.join(TO, path) # path of new dir/symlink
      
      # dir handling
      Util.mkdir(realpath) if File.directory?(fullpath)
      next if File.directory?(fullpath)
      # file handling
      # create symlink in _html/files to physical files _files
      unless File.symlink?(realpath)
        rrealpath = File.join(Dir.getwd, fullpath)
        GPI.print "creating symlink #{realpath} ~> #{rrealpath}", 
          GPI::CLU.check_option('v')
        symlink(rrealpath, realpath)
        GPI.print "created symlink #{realpath} ~> #{rrealpath}",
          GPI::CLU.check_option('v')
      end
      # handle file types embedded in posts
      if Image.is_valid?(fullpath)
        GPI.print "processing #{fullpath} as image file",
          GPI::CLU.check_option('v')
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
    # create dir copies in TO
  end

  def self.symlink(from, to)
    File.symlink(from, to)
  end

end

class FileObject
end