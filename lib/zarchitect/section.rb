class Section < Zarchitect

  # @@config[:sections][:"#{@name}"][:layout]
  ########################
  # Instance Variables
  # @name | Name of section
  def initialize(name)
    @name = name
    p self.config
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

end
