class HTML < Zarchitect
  
  def initialize(url)
    @data = Hash.new
    @url = url
  end

  def set_data(key, value)
    @data[key] = value
  end

end
