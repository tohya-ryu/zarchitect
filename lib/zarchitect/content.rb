class Content < Zarchitect
  attr_reader :html

  def initialize(path)
    i = 0
    YAML.load_stream(File.open(path) { |f| f.read }) do |doc|
      @raw = doc if i == 1
      i += 1
    end
  end

  def markup
    @html = @raw
  end

  private

  def media_img
  end

  def media_img_full
  end

  def media_video
  end

  def media_youtube
  end

  def media_audio
  end

end
