class SCSS

  def self.run
    if Zarchitect.conf.has_option? "scss_enabled"
      Zarchitect.conf.read("scss_enabled").each do |str|
        path = File.join("_assets", str)
        npath = path.clone
        npath.gsub!(".scss", ".css")
        update(path, npath)
      end
    else
      Dir[ File.join("_assets", "**", "*") ].reverse.reject do |path|
        unless File.directory?(path)
          if File.extname(path) == ".scss"
            npath = path.clone
            npath.gsub!('.scss', '.css')
            update(path, npath)
          end
        end
      end
    end
  end

  def self.update(path, npath)
    cmd = "scss #{path} #{npath}"
    GPI.print cmd
    r = %x{ #{cmd} }
    GPI.print r unless r == ""
  end

end

