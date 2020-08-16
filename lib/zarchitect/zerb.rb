class ZERB < Zarchitect
  attr_reader :output

  def initialize(template)
    @renderer = ERB.new(File.open(template) { |f| f.read})
  end

  def include(file)
    File.open(file) { |f| f.read }
  end

  def render
    @output = @renderer.result(binding())
  end

end
