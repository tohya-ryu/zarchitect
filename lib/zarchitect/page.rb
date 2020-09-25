class Page < Zarchitect
  attr_reader :source_path, :html_path, :name, :category, :url, :date, :draft,
    :section, :content, :description

  #+++++++++++++++++++++++++++++++++++
  # @content
  @@current_page = nil

  def initialize(section, source_path, category = nil)
    GPI.print "Initializing page from #{source_path} ...",
      GPI::CLU.check_option('v')
    @section     = section
    @source_path = source_path
    @config      = Hash.new
    @category    = category
    @date        = nil
    @draft       = false

    read_config
    read_content

    if @config.has_key?('title')
      @name = @config['title']
    elsif @seciton.config.has_key?(:default_title)
      @name = @section.config(:default_title)
    else
      @name = ""
    end

    if @config.has_key?('description')
      @description = @config['description'].dump
    else
      @description = @content.html.clone
      @description = @description[0..160]
      @description = Sanitize.fragment(@description)
      if @description.length > 0
        @description[(@description.length-1)] = "…"
      end
      @description = @description.dump
    end

    @id   = @config['id']
    if @config.has_key?('draft')
      @draft = @config['draft']
    end

    if @section.collection?
      if @section.categorized?
        @url = "/#{@section.name}/#{@category.name}/#{@id}/index.html"
        if @draft
          Util.mkdir(File.join("_draft", @section.name, @category.name,
                               "#{@id}"))
        else
          Util.mkdir(File.join("_html", @section.name, @category.name,
                               "#{@id}"))
        end
      else
        @url = "/#{@section.name}/#{@id}/index.html"
        if @draft
          Util.mkdir(File.join("_draft", @section.name, "#{@id}"))
        else
          Util.mkdir(File.join("_html", @section.name, "#{@id}"))
        end
      end
    else
      @url   = "/#{@section.name}/index.html"
    end
    @html_path = @url.clone
    if @draft
      @html_path = File.join(Dir.getwd, "_draft", @url)
    else
      @html_path = File.join(Dir.getwd, "_html", @url)
    end

    GPI.print "... to #{@html_path},",
      GPI::CLU.check_option('v')
    GPI.print "with URL #{@url}", GPI::CLU.check_option('v')

    if @section.collection?
      if @section.config(:sort_type) == "date"
        unless @config.has_key?('date')
          GPI.print "Error: Date missing in #{@source_path}"
          GPI.quit
        else
          @date = @config['date'] # class Time
        end
      end
    end
    rss.try_item(self)
  end

  def read_content
    @content = Content.new(@source_path)
    @content.markup
  end

  def update
    @@current_page = self
    GPI.print "Updating HTML for #{@source_path}", GPI::CLU.check_option('v')
    #read_content
    layout_tmpl = ZERB.new(@section.config[:layout])
    view_tmpl   = ZERB.new(@section.config[:view])
    view_tmpl.set_data(:content, @content.html)
    # prepare meta information
    if @section.collection?
      title = Config.site_name.clone
      title << Config.title_sep
      title << @config['title']
      layout_tmpl.set_meta(:title, title.dump)
    else
      title = Config.site_name.clone
      title << Config.title_sep
      title << @config['title']
      layout_tmpl.set_meta(:title, title.dump)
    end
    keywords = Config.site_keywords.clone
    if @section.config.has_key?(:keywords)
      keywords << ', ' << @section.config[:keywords]
    end
    if @config.has_key?('keywords') && !(@config['keywords'].nil?)
      keywords << ', ' << @config['keywords']
    end
    layout_tmpl.set_meta(:keywords, keywords.dump)
    if @config.has_key?('author')
      author = @config['author'].dump
    else
      author = ""
    end
    layout_tmpl.set_meta(:author, author)
    layout_tmpl.set_meta(:description, @description)
    # set page data
    # prepare content
    view_tmpl.set_data(:title, @name)
    view_tmpl.prepare
    view_tmpl.render
    view_html = view_tmpl.output
    layout_tmpl.set_data(:view, view_html)
    layout_tmpl.prepare
    layout_tmpl.render
    @html = layout_tmpl.output
    # check if write out is required
    unless File.exist?(@html_path)
      write
      GPI.print "Wrote #{@html_path}", GPI::CLU.check_option('v')
    else
      prev_html = File.open(@html_path, 'r') { |f| f.read }
      if prev_html.eql? @html
        GPI.print "Skipped writing #{@html_path} - no update necessary",
          GPI::CLU.check_option('v')
      else
        write
        GPI.print "Overwrote #{@html_path}", GPI::CLU.check_option('v')
      end
    end
  end

  def read_config
    GPI.print "reading config...", GPI::CLU.check_option('v')
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

  def self.current_page
    @@current_page
  end

  private

  def write
    File.open(@html_path, "w") { |f| f.write(@html) }
  end

end
