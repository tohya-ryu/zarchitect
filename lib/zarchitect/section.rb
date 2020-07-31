class Section < Zarchitect

  # @@config[:sections][:"#{@name}"][:layout]
  ########################
  # Instance Variables
  # @name | Name of section
  def initialize(name)
    @name = name
  end

  def collection?
    if @@config[:sections][:"#{@name}"].has_key?(:collection)
      key = @@config[:sections][:"#{@name}"][:collection]
    else 
      key = false
    end
    key
  end

end
