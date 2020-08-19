class Section < Zarchitect
    attr_reader :name

  # @@config[:sections][:"#{@name}"][:layout]
  ########################
  # Instance Variables
  # @name       | str
  # @files      | arr
  # @categories | arr
  def initialize(name)
    # Set instance variables
    @name = name

    # create section directory if necessary
    unless Dir.exist?("_html/#{@name}")
      Dir.mkdir(File.join(Dir.getwd, "_html", @name))
      GPI.print "Created directory _html/#{@name}", GPI::CLU.check_option('v')
    end

    if collection?
      # create category directories if necessary
      @categories = Dir.directories(config[:path])
      @categories.each do |c|
        unless Dir.exist?("_html/#{@name}/#{c}")
          d =  File.join(Dir.getwd, "_html", @name, c)
          Dir.mkdir(d)
          GPI.print "Created directory #{d}", GPI::CLU.check_option('v')
        end
      end
      # create page directories if necessary
    end

    # Read categories
    if config.has_key?(:categorize) && config[:categorize]
    end
  end

  def update(page)
    if collection?
    else
      # create / update a single page
      p = Page.new(self, File.join(Dir.getwd, config[:path]))
      if p.require_update?
        p.read_config
        p.read_content
        p.update
      else
        GPI.print "Ignoring #{p.source_path} (no update necessary)",
          GPI::CLU.check_option('v')
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

  def config
    #@@config[:sections][:"#{@name}"]
    Config.sections[:"#{@name}"]
  end

  private 

  def self.find(str)
    ObjectSpace.each_object(Section) do |o|
      return o if o.name == str
    end
    nil
  end

end
