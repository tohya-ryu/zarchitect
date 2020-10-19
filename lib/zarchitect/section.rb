class Section < Zarchitect
  attr_reader :key

  def initialize(conf)
    GPI.print "Initializing Section #{conf.key}.", GPI::CLU.check_option('v')
    @conf = conf
    @key = conf.key
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
    fetch_categories
    fetch_pages
    @categories.each { |c| c.fetch_tags }
  end

  private

  def create_dir
    unless @conf.index
      Util.mkdir(File.join(HTMLDIR, @conf.key))
    end
  end

  def fetch_categories
    if @conf.collection && @conf.categorize
      @conf.categories.each do |k,v|
        @categories.push Category.new(k, v, self)
      end
    end
  end

  def fetch_pages
    return unless @conf.has_option?("directory")
    Dir.filesr(@conf.directory).each do |f|
      # works!
    end
  end

end
