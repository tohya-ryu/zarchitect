class ZERB < Zarchitect

  #++++++++++++++++++++++++++++++
  # @@template_stack
  # @@gdata
  # @template
  # @path
  # @renderer
  # @output
  # @meta
  # @data
  # 

  @@template_stack = Array.new
  @@gdata          = Hash.new

  def initialize(template)
    @@template_stack.push(template)
    @template = template
    @meta     = Hash.new
    @data     = Hash.new
  end

  def prepare
    @renderer = ERB.new(File.open(@template) { |f| f.read})
  end


  def render
    @out = @renderer.result(binding())
  end

  def output
    @@template_stack.pop
    @out
  end

  def set_meta(key, value)
    if @meta.has_key?(key)
      GPI.print "key #{key} already exists in ZERB.meta"
      GPI.quit
    end
    @meta[key] = value
  end

  def set_data(key, value)
    if @data.has_key?(key)
      GPI.print "key #{key} already exists in ZERB.data"
      GPI.quit
    end
    if @@gdata.has_key?(key)
      GPI.print "key #{key} already exists in ZERB.gdata"
      GPI.quit
    end
    @data[key] = value
  end

  def self.set_gdata(key,value)
    if @@gdata.has_key?(key)
      GPI.print "key #{key} already exists in ZERB.gdata"
      GPI.quit
    end
    @@gdata[key] = value
  end

  private # functions to be used in templates

  def meta(k)
    unless @meta.has_key?(k)
      GPI.print "Error: missing meta key #{k}"
      GPI.quit
    end
    @meta[k] 
  end

  def data(k)
    unless @data.has_key?(k) || @@gdata.has_key?(k)
      GPI.print "Error: missing data key #{k}"
      GPI.quit
    end
    return @@gdata[k] if @@gdata.has_key?(k)
    @data[k] 
  end

  def include(path)
    path.prepend("_layouts/")
    GPI.print "Including #{path} into " \
      "#{@@template_stack[@@template_stack.size-1]}",
      GPI::CLU.check_option('v')
    if @@template_stack.include?(path)
      GPI.print "Error: Recursive call to include"
      GPI.quit
    end
    b = ZERB.new(path)
    b.prepare
    b.render
    b.output
    #File.open(File.join(@path, file)) { |f| f.read }
  end

  def img(path, options = {})
    tag = %{<img src="#{path}"}
    options.each do |k,v|
      tag << %{ #{k.to_s}="#{v}"}
    end
    tag << %{>}
  end

  def link(str, path, options = {})
    tag = %{<a href="#{path}"}
    options.each do |k,v|
      tag << %{ #{k.to_s}="#{v}"}
    end
    tag << %{>#{str}</a>}
  end

  def email(f)
    Config.email if f
    #TODO secure email
    Config.email
  end

  def root_url
    Config.url
  end

  def site_name
    Config.site_name
  end

  def site_slogan
    Config.site_slogan
  end

end
