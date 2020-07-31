require 'yaml'
require 'tohya_gem_interface'

class Zarchitect < TohyaGemInterface

  #
  COMMANDS = ['update', 'publish']

  def main
    # Load config
    @@config = Hash.new
    begin
      File.open('config.yaml') { |f| @@config = YAML.load(f) }
    rescue StandardError
      puts "Could not load config.yaml"
      quit
    end
    check_command(COMMANDS, ARGV[0])
    case ARGV[0]
    when 'update'
      if ARGV.length > 1
        # Update single section
        list = Array.new
        @@config[:sections].each_key do |k|
          list.push(k)
        end
        check_command(list, ARGV[1])
        if ARGV.length > 2
          # Check if ARGV[2] is valid ID
          # Update single post
        else
          # Update all new posts
        end
      else
        # Update all sections
        @@config[:sections].each_key do |k|
          sec = Section.new(k)
          sec.collection?
        end
      end
      # Update Index
    when 'publish'
    end
  end

  private

  require 'zarchitect/index.rb'
  require 'zarchitect/section.rb'
  require 'zarchitect/page.rb'

end
