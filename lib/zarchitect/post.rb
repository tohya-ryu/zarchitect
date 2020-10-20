class Post < Zarchitect

  def initialize(path, section)
    @section = section
    @source_path = path
    @conf = Config.new(path)
    @conf.validate_post
    
  end

end
