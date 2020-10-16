class Image
  attr_reader :dimensions, :size, :type
  attr_writer :thumbs_f, :thumbl_f

  @@search = false
  THUMB_ROOT = "_html"

  #+++++++++++++++++++++++++++++
  # @path
  # @url
  # @dimensions
  # @size
  # @thumbs_f | flags
  # @thumbl_f
  # @type | PNG, JPEG, BMP, GIF

  def initialize(path, f)
    @thumbf = f
    @path = path
    unless @thumbf
      @url  = path.clone
      @url[0] = "/" # replace _ with /
    else
      # thumbnail
      @url  = path[(THUMB_ROOT.length)..-1]
    end
    @dimensions = Point.new(0,0)
    #=============================== [0] = realpath
    # [1] = type
    # [2] = Dimensions
    #=============================== [3] = Dimensions+?+?
    #=============================== [4] = Color depth
    #=============================== [5] = Color space
    #=============================== [6] = Bytes // not accurate for ani-gif
    #=============================== [7] = ?
    #=============================== [8] = ?
    arr = %x{identify #{@path}}.split(" ")
    dim = arr[2].split("x")
    @dimensions.x = dim[0].to_i
    @dimensions.y = dim[1].to_i
    #@size         = arr[6].to_i
    @size         = File.size(path)
    @type         = arr[1]
    # validate file size
    if @size > Zarchitect.conf.image_limit.to_f.mib_to_bytes
      GPI.print "Error: File #{path} too large "\
        "(#{@size.bytes_to_mib.to_f.round(2)}MiB)."\
        " Allowed size: #{Zarchitect.conf.image_limit.to_f.mb_to_mib.round(2)}"
      GPI.quit
    end
  end

  def thumb_small?
    @thumbs_f
  end

  def thumb_large?
    @thumbl_f
  end

  def url
    if (!(Page.current_page.nil?) && Page.current_page.draft && !@@search)
      "../_draft#{@url}"
    else
      @url
    end
  end

  def larger_than_thumb_small?
    @dimensions.x > Zarchitect.conf.thumbs[0].to_i ||
      @dimensions.y > Zarchitect.conf.thumbs[1].to_i
  end

  def larger_than_thumb_large?
    @dimensions.x > Zarchitect.conf.thumbl[0].to_i ||
      @dimensions.y > Zarchitect.conf.thumbl[1].to_i
  end

  def create_thumbnail(path, thumb_x, thumb_y)
    GPI.print "attempting to create thumbnail #{path}",
      GPI::CLU.check_option('v')
    return false if path.include?("/share/") # no thumbs for external files
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

  def self.is_valid?(filename)
    [".png",".gif",".jpg",".jpeg",".bmp"].include?(File.extname(filename))
  end

  def self.find(k, v)
    @@search = true
    # o = Image.find("url", "/files/projects/tre/screen1.png") // usage
    GPI.print "Looking for img: #{v}", GPI::CLU.check_option('v')
    ObjectSpace.each_object(ImageSet) do |set|
      str = set.orig.send(k)
      #GPI.print "v:   #{v}", GPI::CLU.check_option('v')
      #GPI.print "str: #{str}", GPI::CLU.check_option('v')
      if str == v
        GPI.print "Image found", GPI::CLU.check_option('v')
        @@search = false
        return set
      end
    end
    @@search = false
    nil
  end
  
end

class Point
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

end
