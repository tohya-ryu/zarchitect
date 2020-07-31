class Section < Zarchitect

  ########################
  # Instance Variables
  # @name | Name of section
  def initialize(name)
    @name = name
    p @@config[:sections][:"#{name}"]
    p @@config[:sections][:"#{name}"][:layout]
  end

end
