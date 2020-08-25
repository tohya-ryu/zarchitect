class ImageSet

  def initialize(path, fullpath, realpath)
    # path = /section/title/img.png
    # fullpath = _files/section/title/img.png
    # realpath = _html/files/section/title/img.png
    @orig = Image.new(path)
    arr = %x{identify #{realpath}}.split(" ")
    #=============================== [0] = realpath
    # [1] = type
    # [2] = Dimensions
    #=============================== [3] = Dimensions+?+?
    #=============================== [4] = Color depth
    #=============================== [5] = Color space
    # [6] = Bytes
    #=============================== [7] = ?
    #=============================== [8] = ?
    dim = arr[2].split("x")
    @orig.set_data(dim[0], dim[1], arr[6])
  end

end

class Image
  attr_reader :dimensions, :size

  #+++++++++++++++++++++++++++++
  # @path
  # @url
  # @dimensions
  # @size

  def initialize(path)
    @dimensions = Point.new(0,0)
  end

  def set_data(x, y, s)
    @dimensions.x = x
    @dimensions.y = y
    @size         = s
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
