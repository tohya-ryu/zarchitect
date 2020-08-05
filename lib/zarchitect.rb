require 'yaml'
require 'gpi'

class Zarchitect

  #

  def initialize
    GPI.app_name = "zarchitect"
    GPI::CLU.init
    # Command name | range of parameter num | options
    GPI::CLU.use_command("update", 0..2, "r")
    #app_command(0..2, "r") # appname = command.name
    GPI::CLU.use_command("sync", 1, "") # paramter=section to sync
    GPI::CLU.process_args
  end

  def main
    # Load config
    @@config = Hash.new
    #@@options = Hash.new { rebuild: nil }
    begin
      File.open('_config.yaml') { |f| @@config = YAML.load(f) }
    rescue StandardError
      puts "Could not load config.yaml"
      quit
    end
    case GPI::CLU.command
    when 'update'
      if GPI::CLU.parameters.length >= 1
        # update single section
        list = Array.new
        @@config[:sections].each_key do |k|
          list.push(k)
        end
        # check paramter for validity
        unless list.include?(GPI::CLU.parameters[0])
          puts "Invalid parameter to command #{GPI::CLU.command}"
          puts "Valid parameters:"
          list.each do |i|
            puts "- #{i}"
          end
          quit
        end
        if GPI::CLU.parameters.length == 2
          # check if ARGV[2] is valid ID
          # update single post
        else
          # update all new posts
        end
      else
        # Update all sections
        @@config[:sections].each_key do |k|
          sec = Section.new(k)
          if sec.collection?
            # consider section index
          else
            # no section index
          end
        end
      end
      # update Index
    when 'sync'
      # draw data from mastodon / twitter api
    end
  end

  private

end

require 'zarchitect/index.rb'
require 'zarchitect/section.rb'
require 'zarchitect/page.rb'
