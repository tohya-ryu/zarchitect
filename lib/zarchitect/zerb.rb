class ZERB < Zarchitect
  attr_reader :output

  def initialize(template)
    @template = template
    @path     = template.clone
    i = @path.length - 1
    while i >= 0 do
      break if @template[i] == '/'
      @path.chop!
      i -= 1
    end
  end

  def prepare
    @renderer = ERB.new(File.open(@template) { |f| f.read})
  end


  def render
    @output = @renderer.result(binding())
  end

  private # functions to be used in templates

  def meta(k)
    Config.meta[k] 
  end

  def include(file)
    b = ZERB.new(File.join(@path, file))
    b.prepare
    b.render
    b.output
    #File.open(File.join(@path, file)) { |f| f.read }
  end

end
