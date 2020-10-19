class Category < Zarchitect

  def initialize(key, name, section)
    @key = key
    @name = name
    @section = section
    @url  = "/#{@section.conf.key}/#{@key}/index.html"

    create_dir
  end


  private

  def create_dir
    Util.mkdir(File.join(HTMLDIR, @section.conf.key, @key))
  end

end
