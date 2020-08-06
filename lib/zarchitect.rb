require 'yaml'
require 'gpi'

class Zarchitect

  #

  def initialize
    GPI.app_name = "zarchitect"
    GPI::CLU.init
    # Command name | range of parameter num | options
    GPI::CLU.use_command("update", 0..2, "rv")
    #app_command(0..2, "r") # appname = command.name
    GPI::CLU.use_command("sync", 1, "") # paramter=section to sync
    GPI::CLU.process_args
  end

  def main
    if GPI::CLU.check_option('v')
      GPI.print "Verbose Mode"
    else
      GPI.print "Non-verbose Mode"
    end
    # Load config
    @@config = Hash.new
    #@@options = Hash.new { rebuild: nil }
    begin
      File.open('_config.yaml') { |f| @@config = YAML.load(f) }
    rescue StandardError
      GPI.print "Could not load config.yaml"
      GPI.quit
    end
    prepwork
    case GPI::CLU.command
    when 'update'
      if GPI::CLU.parameters.length >= 1
        # update single section
        list = Array.new
        @@config[:sections].each_key do |k|
          list.push(k.to_s)
        end
        # check paramter for validity
        unless list.include?(GPI::CLU.parameters[0])
          GPI.print "Invalid parameter to command #{GPI::CLU.command}"
          GPI.print "Valid parameters:"
          list.each do |i|
            GPI.print "- #{i}"
          end
          GPI.quit
        end
        if GPI::CLU.parameters.length == 2
          # check if ARGV[2] is valid ID
          # update single post
        else
          # update all new posts
          Assets.update
          sec = Section.new(GPI::CLU.parameters[0]) 
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

  def prepwork # create necessary directories etc.
    unless Dir.exist?("_html/assets")
      if GPI::CLU.check_option('v')
        GPI.print "Missing directory _html/assets"
        GPI.print "Creating directory _html/assets"
      end
      Dir.mkdir(File.join(Dir.getwd, "_html", "assets"))
      if GPI::CLU.check_option('v')
        GPI.print "Created directory _html/assets"
      end
    end
  end

end

require 'zarchitect/index.rb'
require 'zarchitect/section.rb'
require 'zarchitect/page.rb'
require 'zarchitect/css.rb'
