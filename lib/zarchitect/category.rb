class Category < Zarchitect
  attr_reader :name, :url

  def initialize(section, name)
    @name = name
    @section = section
    @url  = "/#{@section.name}/#{@name}/index.html"
    @pages_per_index = 0
  end

  def set_pages
    # alrady filtered drafts out
    @pages = @section.rpages.select { |p| p.category.name == @name }
  end

  def create_paginator
    GPI.print "Setting up paginator for #{@section.name}/#{@name}",
      GPI::CLU.check_option('v')
      unless @section.collection?
      GPTI.print "No paginator required (not a collection)",
        GPI::CLU.check_option('v')
      @paginator = nil
      return
    end
    if @section.config[:paginate] && @section.config[:paginate] > 0
      @pages_per_index = @section.config[:paginate]

      paginator_base_url = "/#{@section.name}/#{@name}"
      paginator_num = (@pages.size.to_f / @section.config[:paginate].to_f).ceil

      
      @paginator = Paginator.new(paginator_base_url, paginator_num,
                                @pages_per_index)
    end
  end

  def update_index
    unless @section.config[:paginate] > 0
      @section.create_index(@paginator,
                            "_html/#{@section.name}/#{@name}/index.html",
                            @pages, 0)
    else
      set_pages
      create_paginator
      n = 1
      if @section.config[:paginate] > 0
        n = @paginator.page_number
      end
      GPI.print "Creating #{n} index pages", GPI::CLU.check_option('v')
      i = 0
      while i < n
        if @section.config[:paginate] > 0
          pages = @pages.slice(i * @section.config[:paginate],
                               @section.config[:paginate])
          if i == 0
            path = "_html/#{@section.name}/#{@name}/index.html"
          else
            path = "_html/#{@section.name}/#{@name}/index-#{i+1}.html"
          end
          @section.create_index(@paginator, path, pages, i, n)
        else
          @section.create_index(@paginator,
                                "_html/#{@section.name}/#{@name}/index.html",
                                @pages, i)
        end
        i += 1
        @paginator.next unless @paginator.nil?
      end
    end
  end

end
