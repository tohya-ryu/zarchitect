class Page < Zarchitect

  def initialize(section, source_path)
    @section     = section
    @source_path = source_path
    @html_path   = File.join(Dir.getwd, "_html", @section.name, "index.html")
    p @source_path
    p @html_path
  end

end
