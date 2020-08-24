class ImageSet

  def initialize(path)
    @orig = Image.new(path)
  end

end

class Image

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

  def self.is_valid?(filename)
    [".png",".gif",".jpg",".jpeg",".bmp"].include?(File.extname(filename))
  end
  
end

class Point
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

end
