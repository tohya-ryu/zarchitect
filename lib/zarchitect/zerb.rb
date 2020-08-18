class ZERB < Zarchitect

  #++++++++++++++++++++++++++++++
  # @@template_stack
  # @template
  # @path
  # @renderer
  # @output

  @@template_stack = Array.new

  def initialize(template)
    @@template_stack.push(template)
    @template = template
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

  private # functions to be used in templates

  def meta(k)
    Config.meta[k] 
  end

  def include(path)
    path.prepend("_layouts/")
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

end
