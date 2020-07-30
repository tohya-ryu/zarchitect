require 'yaml'
require 'tohya_gem_interface'

class Zarchitect < TohyaGemInterface

  #
  COMMANDS = ['update', 'publish']

  def run
    # Load config
    @@config = Hash.new
    begin
      File.open('config.yaml') { |f| @@config = YAML.load(f) }
    rescue StandardError
      puts "Could not load config.yaml"
      quit
    end
      check_command(COMMANDS, ARGV[0])
  end

  private

  def check_command(list, cmd)
    if cmd.nil? || !(list.include?(cmd))
      puts "Missing or Invalid Command."
      puts "Legal commands are:"
      list.each { |i| puts "- #{i}" }
      quit
    end
  end

#  def quit
#    exit
#  end


  require 'zarchitect/index.rb'
  require 'zarchitect/section.rb'
  require 'zarchitect/page.rb'

end
