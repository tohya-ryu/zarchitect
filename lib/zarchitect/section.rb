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

    # Open content files
    if self.config[:collection]
      if Dir.exist?(self.config[:path])
        @categories = Dir.get_dir(self.config[:path])
        @categories.map { |s| s.capitalize! }
        Dir.foreach(self.config[:path]) do |fn|
          fopen(File.join(self.config[:path],fn))
        end
      else
        puts "Error: #{self.config[:path]} is not a directory"
        quit
      end
    else
      fopen(self.config[:path])
    end

    @files.each { |f| p f }

    # Read categories
    if self.config.has_key?(:categorize) && self.config[:categorize]
    end
  end

  def collection?
    if self.config.has_key?(:collection)
      key = self.config[:collection]
    else 
      key = false
    end
    key
  end

  def config
    @@config[:sections][:"#{@name}"]
  end

  private 

  def fopen(fn)
    return if File.directory?(fn)
    @files.push(File.open(fn, "r"))
  end

end
