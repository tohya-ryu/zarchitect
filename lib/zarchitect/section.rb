class Section < Zarchitect

  # @@config[:sections][:"#{@name}"][:layout]
  ########################
  # Instance Variables
  # @name       | str
  # @files      | arr
  # @categories | arr
  def initialize(name)
    # Set instance variables
    @name = name
    @files = Array.new

    # create directory if necessary
    unless Dir.exist?("_html/#{@name}")
      Dir.mkdir(File.join(Dir.getwd, "_html", @name))
      GPI.print "Created directory _html/#{@name}", GPI::CLU.check_option('v')
    end
    # Open content files
    if collection?
      if Dir.exist?(config[:path])
        @categories = Dir.directories(config[:path])
        @categories.each do |c|
          p c
        end
        @categories.map { |s| s.capitalize! }
        Dir.foreach(config[:path]) do |fn|
          fopen(File.join(config[:path],fn))
        end
      else
        GPI.print "Error: #{config[:path]} is not a directory"
        GPI.quit
      end
    else
      fopen(config[:path])
    end

    @files.each { |f| p f }

    # Read categories
    if config.has_key?(:categorize) && config[:categorize]
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

  def fopen(fn)
    return if File.directory?(fn)
    @files.push(File.open(fn, "r"))
  end

end
