class Post < Zarchitect
  attr_reader :source_path, :conf, :content, :name, :draft, :date,
    :description, :url, :category

  def initialize(path, section)
    GPI.print "Initializing post #{path}.", GPI::CLU.check_option('v')
    @section = section
    @source_path = path
    @conf = Config.new(path)
    @conf.validate_post
    @id = @conf.id.clone
    @category = nil
    set_draft
    set_date
    fetch_category if @conf.has_option?("category")
    create_dir
    fetch_content 
    set_description
    set_name
    set_url
    set_html_path
    # construct path for html // maybe only necessray when writing html?
    # set date
    rss.try_item(self)
  end

  private

  def fetch_content
    @content = Content.new(self)
    @content.markup
  end

  def fetch_category
    @section.categories.each do |c|
      @category = c if @conf.category == c.key
    end
    if @category.nil?
      GPI.print "Unable to find category #{@conf.category}."
      GPI.quit
    end
  end

  def set_name
    if @conf.has_option?("title")
      @name = @conf.title
    elsif @section.conf.has_option?("default_title")
      @name = @sectin.conf.default_title
    else
      @name = ""
    end
  end

  def set_url
    if @section.conf.collection
      if @section.conf.categorize
        @url = "/#{@section.key}/#{@category.key}/#{@id}/index.html"
      else
        @url = "/#{@section.key}/#{@id}/index.html"
      end
    else
      @url   = "/#{@section.key}/index.html"
    end
  end

  def set_html_path
    @html_path = @url.clone
    @html_path = File.join(Dir.getwd, HTMLDIR, @url)
  end

  def create_dir
    if @section.conf.collection && @section.conf.categorize
      Util.mkdir(File.join(HTMLDIR, @section.key, @category.key, @id.to_s))
    elsif @section.conf.collection
      Util.mkdir(File.join(HTMLDIR, @section.key, @id.to_s))
    end
  end

  def set_draft
    @draft = false
    @draft = @conf.draft if @conf.has_option?("draft")
  end

  def set_date
    @date = nil
    if @section.conf.collection
      if @section.conf.sort_type == "date"
        unless @conf.has_option?('date')
          GPI.print "Error: Date missing in #{@source_path}"
          GPI.quit
        else
          @date = @conf.date #class Time
        end
      else
        if @conf.has_option?('date')
          @date = @conf.date
        end
      end
    else
      if @conf.has_option?('date')
        @date = @conf.date
      end
    end
    if @date.nil?
      @date = File.stat(@source_path).ctime
    end
  end

  def set_description
    if @conf.has_option?('description')
      @description = @conf.description
    else
      nodes = @content.nodes.select { |n| n.type == "p" }
      if nodes.count > 0
        @description = Sanitize.fragment(nodes[0])
      else
        @description = ""
      end
    end
  end

end
