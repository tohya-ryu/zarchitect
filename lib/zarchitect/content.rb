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
    return nil
    if string.is_a?(String)
      new_string = ""
      regexp = /
        \A
        MEDIA:(?<filetype>img|img_full|video|yt|audio):
        (?<id>[a-zA-Z0-9|./_]+):"(?<caption>.*)":?(?<width>[0-9px%]*)
        /x
      string.each_line do |str|
        m = regexp.match(str)
        if m
          # file tag found
          # replace with corresponding html :)
          # m[0] whole tag
          @caption = m[:caption]
          new_html = ""
          case m[:filetype]
          when 'img'
            if m[:id].count('|') == @caption.count('|')
              @images = ImageFile.find(m[:id].split('|'))
              unless m[:width].empty?
                @max_width = m[:width]
              else
                @max_width = '100%'
              end
              html = render_to_string "main/_image", layout: false
            else
              html = "failed to render media"
            end
          when 'img_full'
            @image = ImageFile.find(m[:id])
            html = render_to_string "main/_image_full", layout: false
          when 'video'
            @video = VideoFile.find(m[:id])
            html = render_to_string "main/_video", layout: false
          when 'audio'
            @audio = AudioFile.find(m[:id])
            html = render_to_string "main/_audio", layout: false
          when 'yt'
            @yt_id = m[:id]
            html = render_to_string "main/_youtube", layout: false
          else
            html = "failed to render media"
          end
          html.each_line do |substr|
            if substr.lstrip
              new_html << substr.lstrip
            else
              new_html << substr
            end
          end
          str.sub! m[0], new_html.chomp!
        end
        new_string << str
      end

      markdown = Redcarpet::Markdown.new(RougeHTML,
                                         autolink: true)
      return markdown.render(new_string)
    else
      return nil
    end
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
