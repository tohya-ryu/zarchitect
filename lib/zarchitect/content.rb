class Content < Zarchitect
  attr_reader :nodes

  def initialize(post)
    @post = post
    @source = @post.source_path.clone
    @source.gsub!('/', '_')
    @source.sub!('.md', '')
    @nodes = Array.new
    return if @post.conf.has_option?("script")
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
  end

  def markup
    from_script if @post.conf.has_option?("script")
    return if @post.conf.has_option?("script")
    if !File.exist?(@post.html_path) || 
        (File.stat(@post.source_path).mtime > File.stat(@post.html_path).mtime)
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

      # process tables
      tfound = false
      tables = Array.new
      ar = new_string.split("\n")
      ar.each_with_index do |l,i| 
        if l[0] == "|" && l[-1] == "|"
          if tfound # part of current table
            tables.last.add_line l
          else # first line of a table
            tables.push HTMLTable.new
            tables.last.add_line l
            tables.last.starts_at i
            tfound = true
          end 
        else
          if tfound # first line after a table!
            tables.last.ends_at i-1
            tfound = false
            tables.last.process
          end
        end
      end

      tables.each do |t|
        ar = t.replace(ar)
      end

      ar.delete_if { |x| x.nil? }
      str = ar.join("\n")

      if @post.conf.has_option?("katex")
        str2 = ""
        tmp = ""
        i = 0
        l = str.length
        while (i < l)
          if str[i] == "<" && str[i+1] == "?" && str[i+2] == "k" &&
              str[i+3] == "t" && str[i+4] == "x"
            i += 5
            tmp = ""
            loop do
              if str[i] == "?" && str[i+1] == ">"
                GPI.print "Rendering Katex string", GPI::CLU.check_option('v')
                str2 << Katex.render(tmp.strip)
                i += 1
                break
              else
                tmp << str[i]
                i += 1
              end
            end
          else
            str2 << str[i]
          end
          i += 1
        end
        str = str2
      end
      markdown = Redcarpet::Markdown.new(RougeHTML,
                                       autolink: true)
      chtml = markdown.render(str)

      parse(chtml)
    else
      parse(nil)
    end

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

  def from_script
    html = %x{ ./#{@post.conf.script} }
    parse(html)
  end

  def parse(html)
    node_dir = Util.mkdir(File.join(NODEDIR, @source))
    debug_dir = File.join(File.join(BUILDIR, DEBUGSDIR), @source)
    if GPI::CLU.check_option('d')
      debug_dir = Util.mkdir(debug_dir)
    end

    if html.nil? || html == "nil\n"
      @post.write_block = true
      GPI.print "Reading notes from build dir", GPI::CLU.check_option('v')
      ar = Dir.files(File.join(node_dir)).sort
      ar.each do |f|
        @nodes.push(Marshal.load(File.read(File.join(node_dir,f))))
        if GPI::CLU.check_option('d') # debug
          f = File.join(File.join(debug_dir), "#{i}.txt")
          File.open(f, "w") { |f| f.write(@nodes.last.html) }
        end
      end
    else
      node = Nokogiri::HTML.fragment(html) do |config|
        config.strict.noblanks
      end

      nodes = node.children.select { |c| c.class == Nokogiri::XML::Element }

      nodes.each_with_index do |n,i|
        @nodes.push ContentNode.new(n)
        File.write(File.join(File.join(node_dir), "#{i}.node"),
                   Marshal.dump(@nodes.last))

        if GPI::CLU.check_option('d') # debug
          f = File.join(File.join(debug_dir), "#{i}.txt")
          File.open(f, "w") { |f| f.write(@nodes.last.html) }
        end

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
