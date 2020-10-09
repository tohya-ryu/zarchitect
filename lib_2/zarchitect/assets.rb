require 'gpi'

module Assets

  FROM = "_assets"
  TO   = "_html/assets"

  def self.update
    Dir[ File.join(FROM, '**', '*') ].reject do |fullpath|
      path = fullpath[(FROM.length)..-1]
      realpath = File.join(TO, path)

      Util.mkdir(realpath) if File.directory?(fullpath)
      next if File.directory?(fullpath)

      if File.exist?(realpath)
        if File.stat(fullpath).mtime > File.stat(realpath).mtime
          File.copy(fullpath, realpath)
        end
      else
        File.copy(fullpath, realpath)
      end
    end
  end

  def self.cpdirs
    Dir[ File.join(FROM, '**', '*') ].reject do |fullpath|
      path = fullpath[(FROM.length)..-1]
      realpath = File.join(TO, path)

      Util.mkdir(realpath) if File.directory?(fullpath)
    end
  end

=begin
  def self.update
    files = Dir.files("_assets/")
    files.each do |f|
      check = false
      if Config.singleton_methods.include?(:exclude_assets)
        Config.exclude_assets.each do |s|
          check = true if f.ends_with?(s)
          GPI.print "Ignoring asset #{f} because of its filetype" if check
        end
      end
      next if check
      path = File.join("_assets", f)
      path2 = File.join("_html/assets", f)
      if File.exist?(path2)
        if File.stat(path).mtime > File.stat(path2).mtime
          File.copy(path, path2)
        end
      else
        File.copy(path, path2)
      end
    end
    GPI.print "Updated live assets"
  end
=end

end
