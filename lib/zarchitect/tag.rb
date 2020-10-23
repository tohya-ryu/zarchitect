class Tag < Zarchitect
  attr_accessor :category, :name, :key, :url

  def initialize(str, cat)
    @category = cat
    @name = str
    @key = hash(str)
    @url = "/#{@category.section.key}/#{@category.key}/#{@key}/index.html"

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

end
