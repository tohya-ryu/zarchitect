class Image
  attr_reader :dimensions, :size, :type
  attr_writer :thumbs_f, :thumbl_f

  ROOT = "_html"

  #+++++++++++++++++++++++++++++
  # @path
  # @url
  # @dimensions
  # @size
  # @thumbs_f | flags
  # @thumbl_f
  # @type | PNG, JPEG, BMP, GIF

  def initialize(path, f)
    @path = path
    @url  = path[(ROOT.length)..-1]
    @dimensions = Point.new(0,0)
    @thumbf = f
    #=============================== [0] = realpath
    # [1] = type
    # [2] = Dimensions
    #=============================== [3] = Dimensions+?+?
    #=============================== [4] = Color depth
    #=============================== [5] = Color space
    # [6] = Bytes
    #=============================== [7] = ?
    #=============================== [8] = ?
    arr = %x{identify #{@path}}.split(" ")
    dim = arr[2].split("x")
    @dimensions.x = dim[0].to_i
    @dimensions.y = dim[1].to_i
    @size         = arr[6].to_i
    @type         = arr[1]
  end

  def thumb_small?
    @thumbs_f
  end

  def thumb_large?
    @thumbl_f
  end

  def larger_than_thumb_small?
      @dimensions.x > Config.thumbs[0].to_i ||
        @dimensions.y > Config.thumbs[1].to_i
  end

  def larger_than_thumb_large?
      @dimensions.x > Config.thumbl[0].to_i ||
        @dimensions.y > Config.thumbl[1].to_i
  end

  def self.is_valid?(filename)
    [".png",".gif",".jpg",".jpeg",".bmp"].include?(File.extname(filename))
  end

  def create_thumbnail(path, thumb_x, thumb_y)
    GPI.print "attempting to create thumbnail #{path}",
      GPI::CLU.check_option('v')
    return false if path.include?("/ext/") # no thumbs for external files
    x = @dimensions.x
    y = @dimensions.y
    if x <= thumb_x && y <= thumb_y # no need to create thumbnail
      GPI.print "abort thumbnail creation. No thumbnail #{thumb_x}x"\
        "#{thumb_y} necessary", GPI::CLU.check_option('v')
      return false
    end
    if ["PNG", "GIF"].include?(@type)
      # scale
      while true do
        x = x/2
        y = y/2
        break if x <= thumb_x && y <= thumb_y
      end
      if x < 1 || y < 1 
        GPI.print "failed to create #{path}: invalid downsizing",
          GPI::CLU.check_option('v')
        return false
      end
      command = "convert #{@path} -scale #{x}x#{y} #{path}"
      GPI.print "#{command}", GPI::CLU.check_option('v')
      o = %x{#{command}}
      GPI.print o, GPI::CLU.check_option('v')
      return true
    else
      # resize
      command = "convert #{@path} -resize #{thumb_x}x#{thumb_y} #{path}"
      GPI.print "#{command}", GPI::CLU.check_option('v')
      o = %x{#{command}}
      GPI.print o, GPI::CLU.check_option('v')
      return true
    end
  end
  
end

class Point
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

end
