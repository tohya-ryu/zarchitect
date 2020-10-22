class Index < Zarchitect

  def initialize(parent)
    @parent = parent
    @ptype = @parent.class.to_s
    # index owns paginator
    # owns the index files which share its paginator
    setup_paginator
    setup_html
  end

  private

  def setup_paginator
    ppp = 0
    if section.conf.has_option? "paginate"
      ppp = section.conf.paginate # post per page
    end
    pbu = get_paginator_base_url # url used by pagination
    pnm = (posts.count.to_f / ppi.to_f).ceil # numbers of index pages
    @paginator = Paginator.new(pbu, pnm, ppp)
  end

  def setup_html
    @html = Array.new
    if @paginator.posts_per_page == 0
      html = HTML.new(File.join(HTMLDIR, section.name, "index.html"))
      html.set_data("posts", posts)
      @html.push html
      return
    end
    max = 0
    if section.conf.has_option?("maxpages")
      max = section.conf.maxpages
    end
    html = HTML.new
    @html.push html
  end

  def get_paginator_base_url
    case @ptype
    when "Section"
      "/#{section.key}"
    when "Category"
      "/#{section.key}/#{@parent.key}"
    when "Tag"
      "/#{section.key}/#{@parent.category.key}/#{@parent.key}"
    end
  end

  def section
    case @ptype
    when "Section"
      @parent
    when "Category"
      @parent.section
    when "Tag"
      @parent.category.section
    end
  end

  def posts
    @parent.posts.select { |p| !p.draft }
  end

end
