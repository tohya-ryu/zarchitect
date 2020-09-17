class SCSS

  def self.run
    Util.mkdir("_assets")
    Dir[ File.join("_assets", "**", "*") ].reverse.reject do |path|
      unless File.directory?(path)
        if File.extname(path) == ".scss"
          npath = path.clone
          npath.gsub!('.scss', '.css')
          cmd = "scss #{path} #{npath}"
          GPI.print cmd
          r = %x{ #{cmd} }
          GPI.print r unless r == ""
        end
      end
    end
  end

end
