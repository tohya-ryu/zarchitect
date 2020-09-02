class Content < Zarchitect
  attr_reader :html

  def initialize(path)
    @raw = File.open(path) { |f| f.read }
    @raw = @raw.lines
    i = 0
    z = 0
    @raw.each do |l|
      if l.start_with?("---")
        z += 1
      end
      break if z == 2
      i += 1
    end
    @raw = @raw.drop(i+1)
    @raw = @raw.join
  end

  def markup
    GPI.print "Processing markdown", GPI::CLU.check_option('v')
    @html = @raw
    @img_id = 0
    @img_id_inc = 1
    new_string = ""
    regexp = /
      \A
      MEDIA:(?<filetype>img|img_full|video|yt|audio):
      (?<id>[a-zA-Z0-9|._\/]+):"(?<caption>.*)":?(?<width>[0-9px%]*)
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
          GPI.print "Processing media: img", GPI::CLU.check_option('v')
          @img_id += @img_id_inc
          @imgset = Array.new
          if m[:id].count('|') == @caption.count('|')
            m[:id].split('|').each do |id|
              @imgset.push Image.find("url", id)
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
          GPI.print "Processing media: img_full", GPI::CLU.check_option('v')
          @image = Image.find("url", m[:id])
          a = ZERB.new("_layouts/_image_full.html.erb")
          a.set_data(:image, @image)
          a.set_data(:caption, @caption)
          a.prepare
          a.render
          html = a.output
        when 'video'
          GPI.print "Processing media: video", GPI::CLU.check_option('v')
          @video = VideoFile.find(m[:id])
          a = ZERB.new("_layouts/_video.html.erb")
          a.set_data(:video, @video)
          a.set_data(:caption, @caption)
          a.prepare
          a.render
          html = a.output
        when 'audio'
          GPI.print "Processing media: audio", GPI::CLU.check_option('v')
          @audio = AudioFile.find(m[:id])
          a = ZERB.new("_layouts/_audio.html.erb")
          a.set_data(:audio, @audio)
          a.set_data(:caption, @caption)
          a.prepare
          a.render
          html = a.output
        when 'yt'
          @yt_id = m[:id]
          GPI.print "Processing media: youtube", GPI::CLU.check_option('v')
          a = ZERB.new("_layouts/_youtube.html.erb")
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
