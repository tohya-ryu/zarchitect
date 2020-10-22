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
  end

  def prepare
    GPI.print "ZERB preparing #{@template}",
      GPI::CLU.check_option('v')
    @renderer = ERB.new(File.open(@template) { |f| f.read})
  end


  def render
    @out = @renderer.result(binding())
  end

  def output
    @@template_stack.pop
    @out
  end
   
  def handle_data(hash)
    hash.each do |k,v|
      if instance_variable_defined?("#{k}")
        GPI.print "Error: Data key invalid #{k} - already defined"
        GPI.quit
      end
      instance_variable_set("#{k}", v)
    end
  end

  private # functions to be used in templates

  def include(path, options = {})
    path.prepend("_layouts/")
    GPI.print "Including #{path} into " \
      "#{@@template_stack[@@template_stack.size-1]}",
      GPI::CLU.check_option('v')
    if @@template_stack.include?(path)
      GPI.print "Error: Recursive call to include"
      GPI.quit
    end
    b = ZERB.new(path)
    options.each do |k,v|
      b.set_data(k,v)
    end
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

  def fdate(date)
    date.strftime("%F")
  end

  def include_view
    data(:view)
  end

  def include_content
    data(:content)
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

  def origin_year
    Config.origin_year
  end

  def admin
    Config.admin
  end

  def site_slogan
    Config.site_slogan
  end

end
