class Page < Zarchitect
  attr_reader :source_path, :html_path, :name, :category, :url

  #+++++++++++++++++++++++++++++++++++
  # @content

  def initialize(section, source_path, category = nil)
    @section     = section
    @id          = section.id_count.clone
    @source_path = source_path
    @html_path   = File.join(Dir.getwd, "_html", @section.name, "index.html")
    @config      = Hash.new
    @category    = category

    if @section.collection?
      if @section.categorized?
        @url = "/#{@section.name}/#{@category.name}/#{@id}/index.html"
      else
        @url = "/#{@section.name}/#{@id}/index.html"
      end
    else
      @url   = "/#{@section.name}/index.html"
    end

    read_config
    @name = @config['title']

  end

  def update
    @content = Content.new(@source_path)
    @content.markup
    GPI.print "Updating #{@source_path}", GPI::CLU.check_option('v')
    layout_tmpl = ZERB.new(@section.config[:layout])
    view_tmpl   = ZERB.new(@section.config[:view])
    view_tmpl.set_data(:content, @content.html)
    # prepare meta information
    if @section.collection?
    else
      title = Config.site_name.clone
      title << Config.title_sep
      title << @config['title']
      layout_tmpl.set_meta(:title, title)
    end
    keywords = Config.site_keywords.clone
    if @section.config.has_key?(:keywords)
      keywords << ', ' << @section.config[:keywords]
    end
    keywords << ', ' << @config['keywords']
    layout_tmpl.set_meta(:keywords, keywords)
    layout_tmpl.set_meta(:author, @config['author'])
    if @config.has_key?('description')
      layout_tmpl.set_meta(:description, @config['description'])
    else
      desc = @content.html.clone
      desc = desc[0..160]
      desc[-1] = "…"
      layout_tmpl.set_meta(:description, desc)
    end
    # set page data
    # prepare content
    view_tmpl.set_data(:title, @name)
    view_tmpl.prepare
    view_tmpl.render
    view_html = view_tmpl.output
    layout_tmpl.set_data(:view, view_html)
    layout_tmpl.prepare
    layout_tmpl.render
    html = layout_tmpl.output
    File.open(@html_path, "w") { |f| f.write(html) }
    GPI.print "Wrote #{@html_path}", GPI::CLU.check_option('v')
  end

  def read_config
    YAML.load_stream(File.open(@source_path) { |f| f.read }) do |doc|
      @config = doc
      break
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
