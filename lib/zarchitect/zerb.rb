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
    @data = hash
    hash.each do |k,v|
      if instance_variable_defined?("@#{k}")
        GPI.print "Error: Data key invalid #{k} - already defined"
        GPI.quit
      end
      instance_variable_set("@#{k}", v)
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
    b.handle_data(options)
    b.prepare
    b.render
    b.output
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
    @view
  end

  def include_content
    @content
  end

  def email(f)
    Zarchitect.conf.email if f
    #TODO secure email
    Zarchitect.conf.email
  end

  def root_url
    Zarchitect.conf.url
  end

  def site_name
    Zarchitect.conf.site_name
  end

  def origin_year
    Zarchitect.conf.origin_year
  end

  def admin
    Zarchitect.conf.admin
  end

  def site_slogan
    Zarchitect.conf.site_slogan
  end

end
