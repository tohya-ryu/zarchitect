class Video


  def initialize(path)
  end

  def self.is_valid?(filename)
    [".mp4",".avi",".webm"].include?(File.extname(filename))
  end
  
end
