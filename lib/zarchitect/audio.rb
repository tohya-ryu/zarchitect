class Audio


  def initialize(path)
  end

  def self.is_valid?(filename)
    [".mp3",".ogg"].include?(File.extname(filename))
  end
  
end
