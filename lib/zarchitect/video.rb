class Video
  attr_reader :size, :type, :url

  def initialize(path)
    @path = path
    @url = path.clone
    @url[0] = "/"
    @size = File.size(path)
    @type = "audio/" << File.extname(path)[1..-1]

    if @size > Zarchitect.conf.video_limit.to_f.mib_to_bytes
      GPI.print "Error: File #{path} too large "\
        "(#{@size.bytes_to_mib.to_f.round(2)}MiB)."\
        " Allowed size: #{Zarchitect.conf.video_limit.to_f.mb_to_mib.round(2)}"
      GPI.quit
    end
  end

  def self.is_valid?(filename)
    [".mp4",".avi",".webm"].include?(File.extname(filename))
  end

  def self.find(k, v)
    GPI.print "Looking for video: #{v}", GPI::CLU.check_option('v')
    ObjectSpace.each_object(Video) do |a|
      str = a.send(k)
      if str == v
        GPI.print "Video found", GPI::CLU.check_option('v')
        @@search = false
        return a
      end
    end
    @@search = false
    nil
  end
  
end
