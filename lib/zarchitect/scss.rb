class SCSS

  def self.run
    Util.mkdir("_assets")
    Dir[ File.join("_assets", "**", "*") ].reverse.reject do |path|
      unless File.directory?(path)
        if File.extname(path) == ".scss"
          npath = path.clone
          npath.gsub!('.scss', '.css')
          update(path, npath)

=begin
          unless File.exist?(npath)
            update(path, npath)
          else
            if File.stat(path).mtime > File.stat(npath).mtime
              update(path, npath)
            end
          end
=end

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

