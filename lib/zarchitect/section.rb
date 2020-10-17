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
    #fetch_pages
    #set_categories
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

end
