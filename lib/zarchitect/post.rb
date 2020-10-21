class Post < Zarchitect
  attr_reader :source_path, :conf

  def initialize(path, section)
    @section = section
    @source_path = path
    @conf = Config.new(path)
    @conf.validate_post
    fetch_content 
    # set title
    # set url
    # construct path for html // maybe only necessray when writing html?
    # set date
    rss.try_item(self)
  end

  def fetch_content
    @content = Content.new(self)
    @content.markup
  end

end
