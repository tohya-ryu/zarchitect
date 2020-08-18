class ZERB < Zarchitect
  attr_reader :output

  def initialize(template)
    @template = template
  end

  def prepare
    @renderer = ERB.new(File.open(@template) { |f| f.read})
  end

  def include(file)
    File.open(file) { |f| f.read }
  end

  def render
    @output = @renderer.result(binding())
  end

  def get_meta_data
    @meta = Config.meta
    if @meta.has_key?(:keywords)
      @meta[:keywords] = @meta[:keywords].join(",")
    end
  end

end
