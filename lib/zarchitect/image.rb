class ImageSet

  def initialize(path)
  end

end

class Image < File

  #+++++++++++++++++++++++++++++
  # @path
  # @thumbl_path
  # @thumbs_path
  # @url
  # @thumbl_url
  # @thumbs_url
  # @dimensions
  # @thumbl_dimensions
  # @thumbs_dimensions

  def initialize(path)
  end
  
end

class Point
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

end
