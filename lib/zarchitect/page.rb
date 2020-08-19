class Page < Zarchitect
  attr_reader :source_path, :html_path

  #+++++++++++++++++++++++++++++++++++
  # @content

  def initialize(section, source_path)
    @section     = section
    @source_path = source_path
    @html_path   = File.join(Dir.getwd, "_html", @section.name, "index.html")
    @config      = Hash.new
  end

  def update
    GPI.print "Updating #{@source_path}", GPI::CLU.check_option('v')
    a = ZERB.new(@section.config[:layout])
    if @section.collection?
    else
      title = Config.site_name.clone
      title << Config.title_sep
      title << @config['title']
      a.set_meta(:title, title)
    end
    keywords = Config.site_keywords.clone
    if @section.config.has_key?(:keywords)
      keywords << ', ' << @section.config[:keywords]
    end
    keywords << ', ' << @config['keywords']
    a.set_meta(:keywords, keywords)
    a.set_meta(:author, @config['author'])
    a.prepare
    a.render
    html = a.output
    File.open(@html_path, "w") { |f| f.write(html) }
    GPI.print "Wrote #{@html_path}", GPI::CLU.check_option('v')
  end

  def read_config
    YAML.load_stream(File.open(@source_path) { |f| f.read }) do |doc|
      @config = doc
      break
    end
  end

  def read_content
    i = 0
    YAML.load_stream(File.open(@source_path) { |f| f.read }) do |doc|
      @content = doc if i == 1
      i += 1
    end
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
