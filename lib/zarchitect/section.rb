class Section < Zarchitect

  def initialize(conf)
    @conf = conf
    create_dir
  end

  private

  def create_dir
    unless @conf.index
      Util.mkdir(File.join(HTMLDIR, @conf.key))
    end
  end

end
