class FileManager < Zarchitect

  def initialize
    @from = FILEDIR # where user puts files
    @to = File.join(HTMLDIR, FILESDIR) # files in website dir tree

    @img = Array.new
    @audio = Array.new
    @video = Array.new
    @misc  = Array.new
  end

  def run
    # iterate FROM 
    Dir[ File.join(@from, '**', '*') ].reject do |fullpath|
      path = fullpath[(@from.length)..-1]
      realpath = File.join(@to, path) # path of new dir/symlink
      
      # dir handling / create copies in TO
      Util.mkdir(realpath) if File.directory?(fullpath)
      next if File.directory?(fullpath)
      # file handling
      rrealpath = File.join(Dir.getwd, fullpath)
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
      unless File.exist?(realpath)
        if Zarchitect.conf.symlink_assets
          symlink(rrealpath, realpath)
        else
          copy(rrealpath, realpath)
        end
      else
        if File.stat(rrealpath).mtime > File.stat(realpath).mtime
          if Zarchitect.conf.symlink_assets
            symlink(rrealpath, realpath)
          else
            copy(rrealpath, realpath)
          end
        end
      end

    end
  end

  def symlink(from, to)
    GPI.print "creating symlink #{to} ~> #{from}", 
      GPI::CLU.check_option('v')
    File.symlink(from, to)
    GPI.print "created symlink #{to} ~> #{from}",
      GPI::CLU.check_option('v')
  end

  def copy(from, to)
    cmd = "cp #{from} #{to}"
    GPI.print cmd, GPI::CLU.check_option('v')
    unless system(cmd)
      GPI.print "failed to copy '#{from}' to '#{to}'"
      GPI.quit
    end
  end

  def clean
    # remove all files in _html/files
    %x{rm -r _html/files/*} 
  end

end
