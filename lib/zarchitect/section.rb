class Section < Zarchitect

  def initialize(conf)
    GPI.print "Initializing Section #{conf.key}.", GPI::CLU.check_option('v')
    @conf = conf
    @name = @conf.name.clone
    @pages = Array.new
    @categories = Array.new
    @index = Array.new
    if @conf.index
      @url = "/index.html"
    else
      @url = "/#{@conf.key}/index.html"
    end
    create_dir
    fetch_pages
    #set_categories
    #
    p "##########################"
    if @conf.collection && @conf.categorize
      p @conf.categories
    end
  end

  private

  def create_dir
    unless @conf.index
      Util.mkdir(File.join(HTMLDIR, @conf.key))
      if @conf.collection && @conf.categorize
        Dir.directories(@conf.directory).each do |d|
          Util.mkdir(File.join(HTMLDIR, @conf.key, d))
        end
      end
    end
  end

  def fetch_pages
    return unless @conf.has_option?("directory")
    if @conf.collection && @conf.categorize
      Dir.directories(@conf.directory).each do |d|
        path = File.join(Dir.getwd, @conf.key, d)
        #p path
        Dir.files(path).each do |f|
          fpath = File.join(path, f)
          #p fpath
        end
      end
    else
    end
  end

end
