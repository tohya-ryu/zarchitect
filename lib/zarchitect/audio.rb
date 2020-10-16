class Audio
  attr_reader :size, :type, :url

  def initialize(path)
    @path = path
    @url = path.clone
    @url[0] = "/"
    @size = File.size(path)
    @type = "video/" << File.extname(path)[1..-1]

    if @size > Zarchitect.conf.audio_limit.to_f.mib_to_bytes
      GPI.print "Error: File #{path} too large "\
        "(#{@size.bytes_to_mib.to_f.round(2)}MiB)."\
        " Allowed size: #{Zarchitect.conf.audio_limit.to_f.mb_to_mib.round(2)}"
      GPI.quit
    end
  end

  def self.is_valid?(filename)
    [".mp3",".ogg"].include?(File.extname(filename))
  end

  def self.find(k, v)
    ObjectSpace.each_object(Audio) do |a|
      str = a.send(k)
      return a if str == v
    end
    nil
  end
  
end
