class HTML < Zarchitect
  
  def initialize(url)
    @data = Hash.new
    @url = url
  end

  def set_data(key, value)
    @data[key] = value
  end

  def set_meta(key, value)
    @meta[key] = value
  end

  def set_templates(layout, view)
    @layout_path = layout
    @view_path = view
  end

  def compose
    @data["meta"] = @meta
    set_layout
    set_view
  end

  private

  def set_layout
  end

  def set_view
  end

end
