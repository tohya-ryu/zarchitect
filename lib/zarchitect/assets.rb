require 'gpi'

module Assets

  def self.update
    files = Dir.files("_assets/")
    files.each do |f|
      check = false
      if Config.singleton_methods.include?(:exclude_assets)
        Config.exclude_assets.each do |s|
          check = true if f.ends_with?(s)
          GPI.print "Ignoring asset #{f} because of its filetype"
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

end
