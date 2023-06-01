require 'gpi'

class Assets < Zarchitect

  def initialize
    @from = ASSETDIR
    @to = File.join(HTMLDIR, ASSETSDIR)
  end

  def update
    Dir.glob(File.join(@from, '**', '*'), File::FNM_DOTMATCH).reject do |fullpath|
      path = fullpath[(@from.length)..-1]
      next if path[-1] == '.'
      next if path.include?('.sass-cache')

      if path.include?(HTMLDIR)
        realpath = path[1..-1]
      else
        realpath = File.join(@to, path)
        Util.mkdir(realpath) if File.directory?(fullpath)
      end

      next if File.directory?(fullpath)

      if File.exist?(realpath)
        if File.stat(fullpath).mtime > File.stat(realpath).mtime
          copy_file(fullpath, realpath)
        end
      else
        copy_file(fullpath, realpath)
      end
    end
  end

  def cpdirs
    Dir[ File.join(@from, '**', '*') ].reject do |fullpath|
      path = fullpath[(@from.length)..-1]
      if path.include?(HTMLDIR)
        realpath = path[1..-1]
      else
        realpath = File.join(@to, path)
        Util.mkdir(realpath) if File.directory?(fullpath)
      end

    end
  end

  def copy_file(a, b)
    GPI.print "Copying from #{a} to #{b}.", GPI::CLU.check_option('v')
    File.copy(a, b)
  end

end
