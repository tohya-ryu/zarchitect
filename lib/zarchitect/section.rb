class Section < Zarchitect
  attr_reader :name, :url, :pages, :categories, :id_count, :paginator,
    :rpages

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

  end

  def create_paginator
    @rpages = @pages.select { |p| p.draft == false }
    GPI.print "Setting up paginator for #{@name}", GPI::CLU.check_option('v')
    unless collection?
      GPTI.print "No paginator required (not a collection)",
        GPI::CLU.check_option('v')
      @paginator = nil
      return
    end
    if config[:paginate] && config[:paginate] > 0
      @pages_per_index = config[:paginate]

      paginator_base_url = "/#{@name}"
      paginator_num = (@rpages.size.to_f / config[:paginate].to_f).ceil

      
      @paginator = Paginator.new(paginator_base_url, paginator_num)
    end
  end

  def update_pages(page = nil)
    if config.has_key?(:noitems) && config[:noitems]
      GPI.print "Skipping HTML rendering for section #{@name}",
        GPI::CLU.check_option('v')
      return
    end
    if collection?
      @pages.each do |p|
        if p.require_update?
          p.update
        else
          GPI.print "Ignoring #{p.source_path} (no update necessary)",
            GPI::CLU.check_option('v')
        end
      end
    else
      # create / update a single page
      if @pages[0].require_update?
        #@pages[0].read_config
        #@pages[0].read_content
        @pages[0].update
      else
        GPI.print "Ignoring #{@pages[0].source_path} (no update necessary)",
          GPI::CLU.check_option('v')
      end
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
      create_index("_html/#{@name}/index.html",@rpages, 0)
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
            path = "_html/#{@name}/index.html"
          else
            path = "_html/#{@name}/index-#{i+1}.html"
          end
          create_index(path, pages, i, n)
        else
          create_index("_html/#{@name}/index.html", @rpages, i)
        end
        i += 1
        @paginator.next unless @paginator.nil?
      end
    end
    @categories.each do |cat|
      cat.update_index
    end
  end

  def create_index(path, collection, curr_index, max_index = nil)
    if max_index.nil?
      GPI.print "creating #{path}", GPI::CLU.check_option('v')
    else
      GPI.print "creating #{path} (#{curr_index}/#{max_index-1}",
        GPI::CLU.check_option('v')
    end
    layout_tmpl = ZERB.new(config[:index_layout])
    view_tmpl   = ZERB.new(config[:index_view])
    view_tmpl.set_data(:pages, collection)
    view_tmpl.prepare
    view_tmpl.render
    view_html = view_tmpl.output
    layout_tmpl.set_data(:view, view_html)
    # TODO
    layout_tmpl.set_meta(:title, "")
    layout_tmpl.set_meta(:keywords, "")
    layout_tmpl.set_meta(:author, "")
    layout_tmpl.set_meta(:description, "")
    layout_tmpl.prepare
    layout_tmpl.render
    html = layout_tmpl.output
    # write file...
    File.open(path, "w") { |f| f.write(html) }
    GPI.print "Wrote #{path}", GPI::CLU.check_option('v')
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

  def paginates?
    @pages_per_index > 0
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
        end
        # create page directories if necessary
      else
        # create pages
        files = Dir.files(config[:path])
        files.sort!
        files.each do |f|
          next if f[0] == "."
          @pages.push Page.new(self, File.join(Dir.getwd, config[:path], f))
          @id_count += 1
        end
      end
    else
      GPI.print "Processing single page...", GPI::CLU.check_option('v')
      if @name == "index"
        #TODO mirror pages from other sections defined by config(:uses)
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
  end

  private 

  def self.find(str)
    ObjectSpace.each_object(Section) do |o|
      return o if o.name == str
    end
    nil
  end


end
