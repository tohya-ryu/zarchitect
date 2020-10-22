class HTML < Zarchitect
  
  def initialize(url)
    @data = Hash.new
    @url = url
  end

  def set_data(key, value)
    @data[key] = value
  end

  def set_templates(layout, view)
    @layout = layout
    @view = view
  end

end
