class ImageSet
  attr_reader :orig, :thumbs, :thumbl

  def initialize(path, fullpath, realpath)
    @thumbl = nil
    @thumbs = nil
    # path = /section/title/img.png
    # fullpath = _files/section/title/img.png
    # realpath = _html/files/section/title/img.png
    filename  = File.basename(path, ".*")
    extension = File.extname(path)
    realdir   = File.dirname(realpath)
    @orig = Image.new(realpath)
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
    @orig.set_data(dim[0].to_i, dim[1].to_i, arr[6].to_i, arr[1])

    # check if thumbnails exist
    thumbs_path = File.join(realdir, "#{filename}-thumbs", extension)
    thumbl_path = File.join(realdir, "#{filename}-thumbl", extension)
    @orig.thumbs_f = File.exist?(thumbs_path)
    @orig.thumbl_f = File.exist?(thumbl_path)
    unless @orig.thumb_small?
      if @orig.larger_than_thumb_small?
        @orig.create_thumbnail(thumbs_path, Config.thumbs[0].to_i,
                               Config.thumbs[1].to_i)
      end
    end
    unless @orig.thumb_large?
      if @orig.larger_than_thumb_small?
        @orig.create_thumbnail(thumbl_path, Config.thumbl[0].to_i,
                               Config.thumbl[1].to_i)
      end
    end

  end

end

class Image
  attr_reader :dimensions, :size, :type
  attr_writer :thumbs_f, :thumbl_f

  #+++++++++++++++++++++++++++++
  # @path
  # @url
  # @dimensions
  # @size
  # @thumbs_f | flags
  # @thumbl_f
  # @type | PNG, JPEG, BMP, GIF

  def initialize(path)
    @path = path
    @dimensions = Point.new(0,0)
  end

  def set_data(x, y, s, t)
    @dimensions.x = x
    @dimensions.y = y
    @size         = s
    @type         = t
  end

  def thumb_small?
    @thumbs_f
  end

  def thumb_large?
    @thumbl_f
  end

  def larger_than_thumb_small?
      dimensions.x > Config.thumbs[0].to_i ||
        dimensions.y > Config.thumbs[1].to_i
  end

  def larger_than_thumb_large?
      dimensions.x > Config.thumbl[0].to_i ||
        dimensions.y > Config.thumbl[1].to_i
  end

  def self.is_valid?(filename)
    [".png",".gif",".jpg",".jpeg",".bmp"].include?(File.extname(filename))
  end

  def create_thumbnail(path, x, y)
  end
  
end

class Point
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

end
