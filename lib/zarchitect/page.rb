class Page < Zarchitect
  attr_reader :source_path, :html_path

  def initialize(section, source_path)
    @section     = section
    @source_path = source_path
    @html_path   = File.join(Dir.getwd, "_html", @section.name, "index.html")
  end

  def update
    GPI.print "Updating #{@source_path}", GPI::CLU.check_option('v')
    a = ZERB.new(@section.config[:layout])
    a.get_meta_data
    a.prepare
    a.render
    html = a.output
    File.open(@html_path, "w") { |f| f.write(html) }
    GPI.print "Wrote #{@html_path}", GPI::CLU.check_option('v')
  end

  def require_update?
    return true if GPI::CLU.check_option('r')
    if File.exist?(@html_path)
      GPI.print "File #{@html_path} already exists", GPI::CLU.check_option('v')
      return (File.stat(@source_path).mtime > File.stat(@html_path).mtime)
    else
      return true
    end
  end


end
