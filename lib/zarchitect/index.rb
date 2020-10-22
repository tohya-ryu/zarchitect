class Index < Zarchitect

  def initialize(parent)
    @parent = parent
    @type = @parent.class.to_s
    # index owns paginator
    # owns the index files which share its paginator
  end

  private

  def section
    case @type
    when "Section"
      @parent
    when "Category"
      @parent.section
    when "Tag"
      @parent.category.section
    end
  end

end
