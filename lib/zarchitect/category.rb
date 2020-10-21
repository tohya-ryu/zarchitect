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
  end

  private

  def create_dir
    Util.mkdir(File.join(HTMLDIR, @section.key, @key))
  end

end
