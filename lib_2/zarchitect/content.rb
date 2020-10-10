class Content < Zarchitect
  attr_reader :nodes

  def initialize(path, config)
    @source = path.clone
    @source.gsub!('/', '_')
    @source.sub!('.md', '')
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
    @nodes = Array.new
    @config = config
  end

  def markup
    GPI.print "Processing markdown", GPI::CLU.check_option('v')
    chtml = @raw
    @img_id = 0
    @img_id_inc = 1
    new_string = ""
    regexp = /
      \A
      MEDIA:(?<filetype>img|img_full|video|yt|audio):
      (?<id>[a-zA-Z0-9|._\-\/]+):"(?<caption>.*)":?(?<width>[0-9px%]*)
      /x
    chtml.each_line do |str|
      if str.include?('MEDIA')
        GPI.print "media processor: #{str}", GPI::CLU.check_option('v')
      end
      m = regexp.match(str)
      if m
        GPI.print "matched regex", GPI::CLU.check_option('v')
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
              img = Image.find("url", id)
              @imgset.push img unless img.nil?
            end
            @img_id_inc = @imgset.size
            #@images = ImageFile.find(m[:id].split('|'))
            unless m[:width].empty?
              @max_width = m[:width]
            else
              @max_width = '100%'
            end
            if @imgset.count > 0
              a = ZERB.new("_layouts/_image.html.erb")
              if @config.has_key?('force-small-thumb')
                a.set_data(:fst, @config['force-small-thumb'])
              else
                a.set_data(:fst, false)
              end
              a.set_data(:img_id, @img_id)
              a.set_data(:imgset, @imgset)
              a.set_data(:max_width, @max_width)
              a.set_data(:caption, @caption)
              a.prepare
              a.render
              html = a.output
            else
              html = "[img not found]"
            end
          else
            html = "[failed to render media]"
          end
        when 'img_full'
          GPI.print "Processing media: img_full", GPI::CLU.check_option('v')
          @image = Image.find("url", m[:id])
          unless @image.nil?
            a = ZERB.new("_layouts/_image_full.html.erb")
            a.set_data(:image, @image)
            a.set_data(:caption, @caption)
            a.prepare
            a.render
            html = a.output
          else
            html = "[img not found]"
          end
        when 'video'
          GPI.print "Processing media: video", GPI::CLU.check_option('v')
          @video = Video.find("url", m[:id])
          unless @video.nil?
            a = ZERB.new("_layouts/_video.html.erb")
            a.set_data(:video, @video)
            a.set_data(:caption, @caption)
            a.prepare
            a.render
            html = a.output
          else
            html = "[video not found]"
          end
        when 'audio'
          GPI.print "Processing media: audio", GPI::CLU.check_option('v')
          @audio = AudioFile.find(m[:id])
          unless @audio.nil?
            a = ZERB.new("_layouts/_audio.html.erb")
            a.set_data(:audio, @audio)
            a.set_data(:caption, @caption)
            a.prepare
            a.render
            html = a.output
          else
            html = "[audio not found]"
          end
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
          html = "[failed to render media]"
        end
        html.each_line do |substr|
          if substr.lstrip
            new_html << substr.lstrip
          else
            new_html << substr
          end
        end
        if new_html.include?('\n')
          str.sub!(m[0], new_html.chomp!)
        else
          str.sub!(m[0], new_html)
        end
      end
      new_string << str
    end

    markdown = Redcarpet::Markdown.new(RougeHTML,
                                       autolink: true)
    chtml = markdown.render(new_string)

    parse(chtml)

  end

  def html
    str = String.new
    @nodes.each do |n|
      str << n.html
    end
    str
  end

  def preview(n)
    if full_preview?(n)
      html
    else
      str = String.new
      @nodes.each_with_index do |node,i|
        break if i == n
        str << node.html 
      end
      str
    end
  end

  def full_preview?(n)
    (@nodes.count <= n)
  end

  private

  def parse(html)
    debug_dir = File.join("_build/debug", @source)
    if GPI::CLU.check_option('d')
      debug_dir = Util.mkdir(debug_dir)
    end

    node = Nokogiri::HTML.fragment(html) do |config|
      config.strict.noblanks
    end

    nodes = node.children.select { |c| c.class == Nokogiri::XML::Element }

    nodes.each_with_index do |n,i|
      @nodes.push ContentNode.new(n)

      if GPI::CLU.check_option('d') # debug
        f = File.join(debug_dir, "#{i}.txt")
        File.open(f, "w") { |f| f.write(@nodes.last.html) }
      end

    end
  end

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

class ContentNode
  attr_reader :type, :html
  
  def initialize(node)
    @type = node.name
    @html = node.to_html
  end
end