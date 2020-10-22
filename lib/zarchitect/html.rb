class HTML < Zarchitect
  
  def initialize(str)
    @data = Hash.new
    @path = str
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
    set_view
    @data["view"] = @view.output
    @data["meta"] = @meta
    set_layout
  end

  def write
    File.open(@path, "w") { |f| f.write(@layout.output) }
  end

  def output
    @layout.output
  end

  private

  def set_layout
    @layout = ZERB.new(@layout_path)
    @layout.handle_data(@data)
    @layout.prepare
    @layout.render
  end

  def set_view
    @view = ZERB.new(@view_path)
    @view.handle_data(@data)
    @view.prepare
    @view.render
  end

end
