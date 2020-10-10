class Section < Zarchitect
  attr_reader :name, :url, :pages, :categories, :id_count, :paginator,
    :rpages
  attr_accessor :currcat

  # @@config[:sections][:"#{@name}"][:layout]
  ########################
  # Instance Variables
  # @name       | str
  # @url        | str
  # @files      | arr
  # @categories | arr
  # @pages      | arr
  def initialize(name)
    GPI.print "Initializing section #{name}", GPI::CLU.check_option('v')
    # Set instance variables
    @name = name
    @pages = Array.new
    @rpages = nil # pages without drafts
    @categories = Array.new
    @id_count = 0
    if @name == "index"
      @url = "/index.html"
    else
      @url = "/#{@name}/index.html"
    end
    @pages_per_index = 0 # 0 = ALL ON ONE INDEX / no pagination
    @currcat = nil

  end

  def create_paginator
    GPI.print "Setting up paginator for #{@name}", GPI::CLU.check_option('v')
    unless collection?
      GPI.print "No paginator required (not a collection)",
        GPI::CLU.check_option('v')
      @paginator = nil
      return
    end
    if config[:paginate] && config[:paginate] > 0
      @pages_per_index = config[:paginate]

      paginator_base_url = "/#{@name}"
      paginator_num = (@rpages.size.to_f / config[:paginate].to_f).ceil

      
      @paginator = Paginator.new(paginator_base_url, paginator_num,
                                @pages_per_index)
    end
  end

  def update_pages(page = nil)
    if config.has_key?(:noitems) && config[:noitems]
      GPI.print "Skipping HTML rendering for section #{@name}",
        GPI::CLU.check_option('v')
      @pages.each do |p|
        p.read_content
      end
      return
    end
    if collection?
      @pages.each do |p|
        p.update
      end
    else
      # create / update a single page
      @pages[0].update
    end
  end

  def update_index
    if config.has_key?(:noindex) && config[:noindex]
      GPI.print "Skipping index HTML rendering for section #{@name}",
        GPI::CLU.check_option('v')
      return
    end
    max = 0
    max = config(:maxpages) if config.has_key?(:maxpages)
    GPI.print "Updating index(es) for #{@name}", GPI::CLU.check_option('v')
    # only required for collections
    return unless collection?
    # sort pages
    case config[:sort_type]
    when "date"
      @pages.sort_by! { |p| p.date }.reverse!
      @rpages.sort_by! { |p| p.date }.reverse!
    when "alphanum"
      @pages.sort_by! { |p| p.name }
      @rpages.sort_by! { |p| p.name }
    end
    unless config[:paginate] # no pagination, create index with all pages
      create_index(@paginator, "_html/#{@name}/index.html",@rpages, 0)
    else
      n = 1 # number of index.html
      if config[:paginate] > 0
        if max > 0
          n = max
        else
          n = @paginator.page_number
        end
      end
      GPI.print "Creating #{n} index pages", GPI::CLU.check_option('v')
      i = 0
      while i < n
        if config[:paginate] > 0
          pages = @rpages.slice(i * config[:paginate], config[:paginate])
          if i == 0
            if @name == "index"
              path = "_html/index.html"
            else
              path = "_html/#{@name}/index.html"
            end
          else
            path = "_html/#{@name}/index-#{i+1}.html"
          end
          create_index(@paginator, path, pages, i, n)
        else
          create_index(@paginator, "_html/#{@name}/index.html", @rpages, i)
        end
        i += 1
        @paginator.next unless @paginator.nil?
      end
    end
    @categories.each do |cat|
      cat.set_pages
      cat.update_index
    end
  end

  def create_index(paginator, path, collection, curr_index, max_index = nil)
    if max_index.nil?
      GPI.print "creating #{path}", GPI::CLU.check_option('v')
    else
      GPI.print "creating #{path} (#{curr_index}/#{max_index-1}",
        GPI::CLU.check_option('v')
    end

    layout_tmpl = ZERB.new(config[:index_layout])
    view_tmpl   = ZERB.new(config[:index_view])
    view_tmpl.set_data(:pages, collection)
    view_tmpl.set_data(:paginator, paginator)
    view_tmpl.prepare
    view_tmpl.render
    view_html = view_tmpl.output
    layout_tmpl.set_data(:view, view_html)
    layout_tmpl.set_meta(:keywords, Config.site_keywords.clone)
    layout_tmpl.set_meta(:author, Config.admin)
    if @currcat
      layout_tmpl.set_meta(:title, Config.site_name+
                          Config.title_sep + @name +
                          Config.title_sep + @currcat.name)
      layout_tmpl.set_meta(:description, "#{@name} #{@currcat.name}")
    else
      layout_tmpl.set_meta(:title,
                           "#{Config.site_name}#{Config.title_sep}#{@name}")
      layout_tmpl.set_meta(:description, @name)
    end
    layout_tmpl.set_data(:current_section, self)
    layout_tmpl.set_data(:current_category, @currcat)
    layout_tmpl.prepare
    layout_tmpl.render
    html = layout_tmpl.output
    i = 0
    html.gsub!("IceBlog.openPostIMG(1)") do |s|
      i += 1
      "IceBlog.openPostIMG(#{i})"
    end
    i = 0
    html.gsub!("data-id=\"1\"") do |s|
      i += 1
      "data-id=\"#{i}\""
    end
    i = 0
    html.gsub!("post-image-1") do |s|
      i += 1
      "post-image-#{i}"
    end
    i = 0
    html.gsub!("post-image-figure-1") do |s|
      i += 1
      "post-image-figure-#{i}"
    end

    # write file...
    # check if write out is required
    unless File.exist?(path)
      File.open(path, "w") { |f| f.write(html) }
      GPI.print "Wrote #{path}", GPI::CLU.check_option('v')
    else
      prev_html = File.open(path, 'r') { |f| f.read }
      if prev_html == html
        GPI.print "Skipped writing #{path} - no update necessary",
          GPI::CLU.check_option('v')
      else
        File.open(path, "w") { |f| f.write(html) }
        GPI.print "Overwrote #{path}", GPI::CLU.check_option('v')
      end
    end
  end

  def collection?
    if config.has_key?(:collection)
      key = config[:collection]
    else 
      key = false
    end
    key
  end

  def categorized?
    if config.has_key?(:categorize)
      key = config[:categorize]
    else
      key = false
    end
    key
  end

  def config(k = nil, f = false) # key required if f = true
    #@@config[:sections][:"#{@name}"]
    if k
      if Config.sections[:"#{@name}"].has_key?(k)
        return Config.sections[:"#{@name}"][k]
      else
        if f
          GPI.print "Error: Invalid key >> Config.sections[:#{@name}][#{k}]"
          GPI.quit
        else
          return nil
        end
      end
    else
      return Config.sections[:"#{@name}"]
    end
  end

  def create_html_dirs
    return if @name == "index"
    unless Dir.exist?("_html/#{@name}")
      Dir.mkdir(File.join(Dir.getwd, "_html", @name))
      GPI.print "Created directory _html/#{@name}", GPI::CLU.check_option('v')
    end
    if collection? && categorized?
      dirs = Dir.directories(config[:path])
      dirs.each do |d|
        unless Dir.exist?("_html/#{@name}/#{d}")
          dir =  File.join(Dir.getwd, "_html", @name, d)
          Dir.mkdir(dir)
          GPI.print "Created directory #{dir}", GPI::CLU.check_option('v')
        end
      end
    end
  end

  def create_pages
    if collection?
      GPI.print "Processing collection...", GPI::CLU.check_option('v')
      if categorized?
        GPI.print "Processing categories...", GPI::CLU.check_option('v')
        # create category directories if necessary
        dirs = Dir.directories(config[:path])
        dirs.each do |d|
          @categories.push Category.new(self, d)
          # create pages
          files = Dir.files(File.join(Dir.getwd, config[:path], d))
          files.sort!
          files.each do |f|
            next if f[0] == "."
            path = File.join(Dir.getwd, config[:path], d, f)
            @pages.push Page.new(self, path, @categories[@categories.size-1])
            @id_count += 1
          end
          @categories.sort_by! { |c| c.name }
        end
        # create page directories if necessary
      else
        # create pages
        if @name == "index"
          a = config(:uses).split(',')
          a.each do |n|
            ObjectSpace.each_object(Section) do |s|
              if s.name == n
                # get pages
                s.pages.each do |p|
                  @pages.push p.clone
                end
              end
            end
          end
        else
          files = Dir.files(config[:path])
          files.sort!
          files.each do |f|
            next if f[0] == "."
            @pages.push Page.new(self, File.join(Dir.getwd, config[:path], f))
            @id_count += 1
          end
        end
      end
    else
      GPI.print "Processing single page...", GPI::CLU.check_option('v')
      if @name == "index"
        a = config(:uses).split(',')
        a.each do |n|
          ObjectSpace.each_object(Section) do |s|
            if s.name == n
              # get pages
              s.pages.each do |p|
                @pages.push p.clone
              end
            end
          end
        end
      else
        @pages.push Page.new(self, File.join(Dir.getwd, config[:path]))
      end
      @id_count += 1
    end
    @rpages = @pages.select { |p| p.draft == false }
  end

  private 

  def self.find(str)
    ObjectSpace.each_object(Section) do |o|
      return o if o.name == str
    end
    nil
  end


end