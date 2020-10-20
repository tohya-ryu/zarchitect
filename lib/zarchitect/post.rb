class Post < Zarchitect

  def initialize(path, section)
    @section = section
    @source_path = path
    @conf = Config.new(path)
    @conf.validate_post
    # read content
    # set title
    # set url
    # construct path for html // maybe only necessray when writing html?
    # set date
    rss.try_item(self)
  end

end
