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
    if ppp > 0 && section.conf.collection
      pbu = base_url # url used by pagination
      pnm = (posts.count.to_f / ppp.to_f).ceil # numbers of index pages
      @paginator = Paginator.new(pbu, pnm, ppp)
    else
      @paginator = Paginator.new(0,0,0) # no pagination for this index file
    end
  end

  def setup_html
    @html = Array.new
    if @paginator.posts_per_page == 0
      html = HTML.new(File.join(HTMLDIR, section.name, "index.html"))
      html.set_templates(layout, view)
      html.set_data("section", section)
      html.set_data("category", category)
      html.set_data("posts", posts)
      @html.push html
      return
    end
    max = 0
    if section.conf.has_option?("maxpages")
      max = section.conf.maxpages
    end
    n = 1 # number of index.html files we need to create
    if @paginator.posts_per_page > 0
      if max > 0
        n = max
      else
        n = @paginator.page_number
      end
    end
    i = 0
    while i < n
      rposts = posts.slice(i * @paginator.posts_per_page,
                           @paginator.posts_per_page)
      if i == 0
        path = File.join(base_url, "index.html")
      else
        path = File.join(base_url, "index-#{i+1}.html")
      end
      html = HTML.new(path)
      html.set_templates(layout, view)
      html.set_data("section", section)
      html.set_data("category", category)
      html.set_data("posts", rposts)
      html.set_data("paginator", @paginator.clone)
      @html.push html
      i += 1
      @paginator.next
    end
  end

  def base_url
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

  def category
    case @ptype
    when "Section"
      nil
    when "Category"
      @parent
    when "Tag"
      @parent.category
    end
  end

  def posts
    @parent.posts.select { |p| !p.draft }
  end

  def layout
    case @ptype
    when "Section"
      section.conf.index_layout
    when "Category"
      if section.conf.has_option?("category_index_layout")
        section.conf.category_index_layout
      else
        section.conf.index_layout
      end
    when "Tag"
      if section.conf.has_option?("tag_index_layout")
        section.conf.tag_index_layout
      else
        if section.conf.has_option?("category_index_layout")
          section.conf.category_index_layout
        else
          section.conf.index_layout
        end
      end
    end
  end

  def view
    case @ptype
    when "Section"
      section.conf.index_view
    when "Category"
      if section.conf.has_option?("category_index_view")
        section.conf.category_index_view
      else
        section.conf.index_view
      end
    when "Tag"
      if section.conf.has_option?("tag_index_view")
        section.conf.tag_index_view
      else
        if section.conf.has_option?("category_index_view")
          section.conf.category_index_view
        else
          section.conf.index_view
        end
      end
    end
  end

end
