class Post < Zarchitect

  def initialize(path, section)
    @section = section
    @source_path = path
  end

end
