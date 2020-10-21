class Section < Zarchitect
  attr_reader :key, :conf, :name, :categories, :posts

  def initialize(conf)
    GPI.print "Initializing Section #{conf.key}.", GPI::CLU.check_option('v')
    @conf = conf
    @key = conf.key
    @name = @conf.name.clone
    if @conf.index
      @url = "/index.html"
    else
      @url = "/#{@conf.key}/index.html"
    end
    create_dir
    fetch_categories
    fetch_posts
    sort_posts
    if @conf.collection && @conf.categorize
      @categories.each { |c| c.fetch_tags } if @conf.tags
    end
  end

  private

  def fetch_indexes
    @indexes = Array.new
  end

  def create_dir
    unless @conf.index
      Util.mkdir(File.join(HTMLDIR, @conf.key))
    end
  end

  def fetch_categories
    @categories = Array.new
    if @conf.collection && @conf.categorize
      @conf.categories.each do |k,v|
        @categories.push Category.new(k, v, self)
      end
    end
  end

  def fetch_posts
    @posts = Array.new
    return unless @conf.has_option?("directory")
    Dir.filesr(@conf.directory).each do |f|
      @posts.push Post.new(f, self)
    end
  end

  def sort_posts
    return unless @conf.collection
    case @conf.sort_type
    when "date"
      if @conf.sort_order == "reverse"
        @posts.sort_by! { |p| p.date }.reverse!
      else
        @posts.sort_by! { |p| p.date }
      end
    when "alphanum"
      if @conf.sort_order == "reverse"
        @posts.sort_by! { |p| p.name }.reverse!
      else
        @posts.sort_by! { |p| p.name }
      end
    end
  end

end
