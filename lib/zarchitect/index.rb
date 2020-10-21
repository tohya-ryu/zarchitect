class Index < Zarchitect

  def initialize(parent)
    @parent = parent
    @type = @parent.class
    # index owns paginator
    # owns the index files which share its paginator
  end

end
