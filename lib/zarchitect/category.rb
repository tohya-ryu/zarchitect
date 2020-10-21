class Category < Zarchitect
  attr_reader :key, :name

  def initialize(key, name, section)
    @key = key
    @name = name
    @section = section
    @url  = "/#{@section.key}/#{@key}/index.html"

    create_dir
  end

  def fetch_tags
    # after fetch_pages is implemented
    ar = Array.new
    posts.each do |p|
      if p.conf.has_option?("tags")
        p.conf.tags.each { |t| ar.push t }
      end
    end
    ar.sort!.uniq!
    if ar.count == 0
      @tags = nil
    else
      @tags = Array.new
      ar.each { |v| @tags.push Tag.new(v) }
    end
  end

  def posts
    @section.posts.select { |p| p.category == self }
  end

  private

  def create_dir
    Util.mkdir(File.join(HTMLDIR, @section.key, @key))
  end

end
