class ZERB < Zarchitect

  #++++++++++++++++++++++++++++++
  # @@template_stack
  # @template
  # @path
  # @renderer
  # @output
  # @meta

  @@template_stack = Array.new

  def initialize(template)
    @@template_stack.push(template)
    @template = template
    @meta     = Hash.new
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
    @meta[key] = value
  end

  private # functions to be used in templates

  def meta(k)
    unless @meta.has_key?(k)
      GPI.print "Error: missing meta key #{k}"
      GPI.quit
    end
    @meta[k] 
  end

  def include(path)
    unless path[0] == '/'
      path.prepend("_layouts/")
    end
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
