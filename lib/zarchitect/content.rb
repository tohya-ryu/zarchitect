class Content < Zarchitect
  attr_reader :nodes

  def initialize(post)
    @post = post
    @source = @post.source_path.clone
    @source.gsub!('/', '_')
    @source.sub!('.md', '')
    @raw = File.open(@post.source_path) { |f| f.read }
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
      @m = regexp.match(str)
      if @m
        GPI.print "matched regex", GPI::CLU.check_option('v')
        # file tag found
        # replace with corresponding html :)
        # m[0] whole tag
        @caption = @m[:caption]
        new_html = ""
        case @m[:filetype]
        when 'img'
          html = media_img
        when 'img_full'
          html = media_img_full
        when 'video'
          html = media_video
        when 'audio'
          html = media_audio
        when 'yt'
          html = media_youtube
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
          str.sub!(@m[0], new_html.chomp!)
        else
          str.sub!(@m[0], new_html)
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
    debug_dir = File.join(File.join(BUILDIR, DEBUGSDIR), @source)
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
    GPI.print "Processing media: img", GPI::CLU.check_option('v')
    @img_id += @img_id_inc
    @imgset = Array.new
    if @m[:id].count('|') == @caption.count('|')
      @m[:id].split('|').each do |id|
        img = Image.find("url", id)
        @imgset.push img unless img.nil?
      end
      @img_id_inc = @imgset.size
      #@images = ImageFile.find(m[:id].split('|'))
      unless @m[:width].empty?
        @max_width = @m[:width]
      else
        @max_width = '100%'
      end
      if @imgset.count > 0
        hash = Hash.new
        a = ZERB.new("_layouts/_image.html.erb")
        if @post.conf.has_option?('sthumb')
          hash["fst"] = @post.conf.sthumb
        else
          hash["fst"] = false 
        end
        hash["imgid"] = @img_id
        hash["imgset"] = @imgset
        hash["max_width"] = @max_width
        hash["caption"] = @caption
        a.handle_data(hash)
        a.prepare
        a.render
        html = a.output
      else
        html = "[img not found]"
      end
    else
      html = "[failed to render media]"
    end
  end

  def media_img_full
    GPI.print "Processing media: img_full", GPI::CLU.check_option('v')
    @image = Image.find("url", @m[:id])
    unless @image.nil?
      hash = Hash.new
      a = ZERB.new("_layouts/_image_full.html.erb")
      hash["image"] = @image
      hash["caption"] = @caption
      a.handle_data(hash)
      a.prepare
      a.render
      html = a.output
    else
      html = "[img not found]"
    end
  end

  def media_video
    GPI.print "Processing media: video", GPI::CLU.check_option('v')
    @video = Video.find("url", @m[:id])
    unless @video.nil?
      hash = Hash.new
      a = ZERB.new("_layouts/_video.html.erb")
      hash["video"] = @video
      hash["caption"] = @caption
      a.handle_data(hash)
      a.prepare
      a.render
      html = a.output
    else
      html = "[video not found]"
    end
  end

  def media_youtube
    @yt_id = @m[:id]
    hash = Hash.new
    GPI.print "Processing media: youtube", GPI::CLU.check_option('v')
    a = ZERB.new("_layouts/_youtube.html.erb")
    hash["yt_id"] = @yt_id
    hash["caption"] = @caption
    a.handle_data(hash)
    a.prepare
    a.render
    html = a.output
  end

  def media_audio
    GPI.print "Processing media: audio", GPI::CLU.check_option('v')
    @audio = AudioFile.find(@m[:id])
    unless @audio.nil?
      hash = Hash.new
      hash["audio"] = @audio
      hash["caption"] = @caption
      a = ZERB.new("_layouts/_audio.html.erb")
      a.handle_data(hash)
      a.prepare
      a.render
      html = a.output
    else
      html = "[audio not found]"
    end
  end

end

class ContentNode
  attr_reader :type, :html
  
  def initialize(node)
    @type = node.name
    @html = node.to_html
  end
end
