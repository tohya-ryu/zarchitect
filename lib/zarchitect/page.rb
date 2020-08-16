class Page < Zarchitect
  attr_reader :source_path, :html_path

  def initialize(section, source_path)
    @section     = section
    @source_path = source_path
    @html_path   = File.join(Dir.getwd, "_html", @section.name, "index.html")
  end

  def update
  end

  def require_update?
    if File.exist?(@html_path)
      GPI.print "File #{@html_path} already exists", GPI::CLU.check_option('v')
      return (File.stat(@source_path).mtime > File.stat(@html_path).mtime)
    else
      return true
    end
  end


end
