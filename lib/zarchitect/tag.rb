class Tag < Zarchitect
  attr_accessor :category, :name, :key, :url, :index

  def initialize(str, cat)
    @category = cat
    @name = str
    set_key
    @url = "/#{@category.section.key}/#{@category.key}/#{@key}/index.html"
    create_dir
    setup_index
  end

  def posts
    @category.section.posts.select do |p|
      ((p.category == @category) && (p.tags.include?(@name)))
    end
  end

  def build_html
    @index.build_html
  end

  def write_html
    @index.write_html
  end

  private

  def create_dir
    Util.mkdir(File.join(HTMLDIR, @category.section.key, @category.key, @key))
  end

  def setup_index
    @index = Index.new(self)
  end

  def hash(str)
    str2 = String.new
    str.each_char do |c|
      str2 << c.ord.to_s
    end
    str2 = str2.to_i
    str2.to_s(16).downcase
  end

  private 

  def set_key
    if Zarchitect.conf.has_option?("tags")
      @key = Zarchitect.conf.tags.key(@name)
      if (@key == nil)
        @key = Zarchitect.conf.tags.key(@name.downcase)
        if (@key == nil)
          GPI.print "Error: No tag key found for '#{@name}'."
          GPI.quit
        end
      end
    else
      @key = hash(str)
    end
  end

end
