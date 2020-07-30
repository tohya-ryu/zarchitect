require 'yaml'

class Zarchitect

  #
  COMMANDS = ['update', 'publish']

  def run
    # Load config
    @@config = Hash.new
    File.open('config.yaml') { |f| @@config = YAML.load(f) }
    check_command(COMMANDS, ARGV[0])
  end

  private

  def check_command(list, cmd)
    if cmd.nil? || !(list.include?(cmd))
      list.each { |i| p i }
      quit
    end
  end

  def quit
    exit
  end


  require 'zarchitect/index.rb'
  require 'zarchitect/section.rb'
  require 'zarchitect/page.rb'

end
