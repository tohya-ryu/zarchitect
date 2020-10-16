require 'gpi'

class Assets < Zarchitect

  def initialize
    @from = ASSETDIR
    @to = File.join(HTMLDIR, ASSETSDIR)
  end

  def update
    Dir[ File.join(from, '**', '*') ].reject do |fullpath|
      path = fullpath[(from.length)..-1]
      realpath = File.join(@to, path)

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

  def cpdirs
    Dir[ File.join(@from, '**', '*') ].reject do |fullpath|
      path = fullpath[(@from.length)..-1]
      realpath = File.join(@to, path)

      Util.mkdir(realpath) if File.directory?(fullpath)
    end
  end

end
