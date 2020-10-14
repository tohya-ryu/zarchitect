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

end
