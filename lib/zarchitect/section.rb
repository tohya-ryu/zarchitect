class Section < Zarchitect
  attr_reader :key, :conf, :name, :categories, :url

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
      @categories.each do |c|
        c.setup_index
        c.fetch_tags if @conf.tags
      end
    end
    setup_index
  end

  def posts
    if GPI::CLU.check_option('D')
      @posts
    else
      @posts.select { |p| p.draft == false }
    end
  end

  def all_posts
    @posts
  end

  def build_html
    posts.each { |p| p.build_html }
    if @categories
      @categories.each { |c| c.build_html }
    end
    @index.build_html unless @conf.has_option?("file")
  end

  def write_html
    posts.each { |p| p.write_html }
    if @categories
      @categories.each { |c| c.write_html }
    end
    @index.write_html unless @conf.has_option?("file")
  end

  def find_category(key)
    @categories.each do |c|
      return c if c.key == key
    end
    nil
  end

  private

  def setup_index
    @index = Index.new(self) unless @conf.has_option?("file")
  end

  def create_dir
    unless @conf.index
      Util.mkdir(File.join(HTMLDIR, @conf.key))
    end
  end

  def fetch_categories
    return if @conf.index
    @categories = Array.new
    if @conf.collection && @conf.categorize
      @conf.categories.each do |k,v|
        @categories.push Category.new(k, v, self)
      end
    end
  end

  def fetch_posts
    if @conf.index
      ar = @conf.uses.split(',')
      @posts = Array.new
      Zarchitect.sections.each do |v|
        if ar.include? v.key
          v.posts.each do |p|
            @posts.push p
          end
        end
      end
    else
      @posts = Array.new
      if @conf.has_option?("directory")
        Dir.filesr(@conf.directory).each do |f|
          next unless File.extname(f)
          @posts.push Post.new(f, self)
        end
      elsif @conf.has_option?("file")
        @posts.push Post.new(@conf.file, self)
      end
    end
  end

  def sort_posts
    return if @posts.count <= 1
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
