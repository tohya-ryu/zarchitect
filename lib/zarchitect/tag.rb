class Tag < Zarchitect

  def initialize(str, cat)
    @category = cat
    @name = str
    @key = hash(str)
    @url = "/#{@category.section.key}/#{@category.key}/#{@key}/index.html"
  end

  def posts
    @category.section.posts.select {
      |p| p.category == @category &&p.tags.include @name 
    }
  end

  private

  def hash(str)
    str2 = String.new
    str.each_char do |c|
      str2 << c.ord.to_s
    end
    str2 = str2.to_i
    str2.to_s(16).downcase
  end





end