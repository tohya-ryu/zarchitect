require 'yaml'

class Zarchitect

  #

  def run
    # Load config
    @config = Hash.new
    File.open('config.yaml') { |f| @config = YAML.load(f) }

  end

end
