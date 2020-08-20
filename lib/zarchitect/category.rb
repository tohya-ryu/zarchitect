class Category < Zarchitect
  attr_reader :name, :url

  def initialize(section, name)
    @name = name
    @url  = "/#{section.name}/#{@name}/index.html"
  end

end
