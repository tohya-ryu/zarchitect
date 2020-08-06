require 'gpi'

module CSS

  def self.update
    files = GPI::Dir.files("_assets/")
    files.each do |f|
      path = File.join("_assets", f)
=begin
      if File.fnmatch("*.scss", path)
        path2 = File.join("_html/assets", f.gsub(/.scss/, ".css"))
        if File.exists?(path2)
          if File.stat(path).mtime > File.stat(path2).mtime
            %x`sass #{path} #{path2}`
          end
        else
          %x`sass #{path} #{path2}`
        end
      end
=end
      if File.fnmatch("*.css", path)
        path2 = File.join("_html/assets", f)
        if File.exist?(path2)
          if File.stat(path).mtime > File.stat(path2).mtime
            GPI::File.copy(path, path2)
          end
        else
          GPI::File.copy(path, path2)
        end
      end
    end
  end

end
