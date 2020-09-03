class Section < Zarchitect
    attr_reader :name, :url, :pages, :categories, :id_count

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
    @categories = Array.new
    @id_count = 0
    @url = "/#{@name}/index.html"
 end

  def update_pages(page = nil)
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
    GPI.print "Updating index(es) for #{@name}", GPI::CLU.check_option('v')
    # only required for collections
    return unless collection?
    # sort pages
    case config[:sort_type]
    when "date"
      @pages.sort_by! { |p| p.date }.reverse!
    when "alphanum"
      @pages.sort_by! { |p| p.name }
    end
    unless config[:paginate] # no pagination, create index with all pages
      create_index(@pages)
    else
      n = 1 # number of index.html
      if config[:paginate] > 0
        n = (@pages.size.to_f / config[:paginate].to_f).ceil
      end
      GPI.print "n = #{n}", GPI::CLU.check_option('v')
    end
  end

  def create_index(collection)
    layout_tmpl = ZERB.new(config[:index_layout])
    view_tmpl   = ZERB.new(config[:index_view])
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
      @pages.push Page.new(self, File.join(Dir.getwd, config[:path]))
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
