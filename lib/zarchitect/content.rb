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
    @img_id = 0
    @img_id_inc = 1
    new_string = ""
    regexp = /
      \A
      MEDIA:(?<filetype>img|img_full|video|yt|audio):
      (?<id>[a-zA-Z0-9|./_]+):"(?<caption>.*)":?(?<width>[0-9px%]*)
      /x
    @html.each_line do |str|
      m = regexp.match(str)
      if m
        # file tag found
        # replace with corresponding html :)
        # m[0] whole tag
        @caption = m[:caption]
        new_html = ""
        case m[:filetype]
        when 'img'
          @img_id += @img_id_inc
          @imgset = Array.new
          if m[:id].count('|') == @caption.count('|')
            m[:id].split('|').each do |url|
              @imgset.push Image.find("url", m[:id]).split('|'))
            end
            @img_id_inc = @imgset.size
            #@images = ImageFile.find(m[:id].split('|'))
            unless m[:width].empty?
              @max_width = m[:width]
            else
              @max_width = '100%'
            end
            a = ZERB.new("_layouts/_image.html.erb")
            a.set_data(:img_id, @img_id)
            a.set_data(:imgset, @imgset)
            a.set_data(:max_width, @max_width)
            a.set_data(:caption, @caption)
            a.prepare
            a.render
            html = a.output
          else
            html = "failed to render media"
          end
        when 'img_full'
          @image = Image.find(url, m[:id])
          a = ZERB.new("_layouts/_image_full.html.rb")
          a.set_data(:image, @image)
          a.set_data(:caption, @caption)
          a.prepare
          a.render
          html = a.output
        when 'video'
          @video = VideoFile.find(m[:id])
          a = ZERB.new("_layouts/_video.html.rb")
          a.set_data(:video, @video)
          a.set_data(:caption, @caption)
          a.prepare
          a.render
          html = a.output
        when 'audio'
          @audio = AudioFile.find(m[:id])
          a = ZERB.new("_layouts/_audio.html.rb")
          a.set_data(:audio, @audio)
          a.set_data(:caption, @caption)
          a.prepare
          a.render
          html = a.output
        when 'yt'
          @yt_id = m[:id]
          a = ZERB.new("_layouts/_youtube.html.rb")
          a.set_data(:yt_id, @yt_id)
          a.set_data(:caption, @caption)
          a.prepare
          a.render
          html = a.output
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
    @html = markdown.render(new_string)
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
