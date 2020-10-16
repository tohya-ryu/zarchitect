class Section < Zarchitect

  def initialize(conf)
    @conf = conf
    unless @conf.index
      Util.mkdir(File.join(HTMLDIR, @conf.name))
    end
  end

end
