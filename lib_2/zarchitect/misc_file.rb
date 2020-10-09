class MiscFile
  attr_reader :size, :type, :url

  def initialize(path)
    @path = path
    @url = path.clone
    @url[0] = "/"
    @size = File.size(path)
    @type = File.extname(path)[1..-1]
  end

  def self.find(k, v)
    ObjectSpace.each_object(MiscFile) do |a|
      str = a.send(k)
      return a if str == v
    end
  end
  
end
