require 'yaml'
require 'erb'
require 'gpi'

class Zarchitect

  #

  def initialize
    GPI.app_name = "zarchitect"
    GPI.extend(:dir)
    GPI.extend(:file)
    GPI.extend(:hash)
    GPI.extend(:numeric)
    GPI.extend(:string)
    GPI::CLU.init
    # Command name | range of parameter num | options
    GPI::CLU.use_command("update", 0..2, "rvq")
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
    conf = Hash.new
    #@@options = Hash.new { rebuild: nil }
    begin
      File.open('_config.yaml') { |f| conf = YAML.load(f) }
    rescue StandardError
      GPI.print "Could not load config.yaml"
      GPI.quit
    end
    case GPI::CLU.command
    when 'update'
      #FileManager.clean if GPI::CLU.check_option('r')
      if GPI::CLU.check_option('r') # rebuild
        Dir[ File.join("_html", "**", "*") ].reverse.reject do |fullpath|
          if File.directory?(fullpath)
            GPI.print "deleting dir #{fullpath}"
            Dir.delete(fullpath)
            GPI.print "deleted dir #{fullpath}"
          else
            GPI.print "deleting file #{fullpath}"
            File.delete(fullpath)
            GPI.print "deleted file #{fullpath}"
          end
        end
      end
      prepwork
      conf.to_module("Config")
      if GPI::CLU.check_option('q')
        GPI.print "skipping file updates", GPI::CLU.check_option('v')
      else
        FileManager.run
      end
      # prepare data for use in templates
      data = Hash.new
      Config.sections.each_key do |k|
        s = Section.new(k.to_s)
        data[:"#{s.name}"] = s
      end
      ZERB.set_gdata(:sections, data)
      if GPI::CLU.parameters.length >= 1
        # update single section
        list = Array.new
        Config.sections.each_key do |k|
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
          Assets.update
          section = Section.find(GPI::CLU.parameters[0])
          section.update(GPI::CLU.parameters[1])
        else
          # update all new posts
          Assets.update
          section = Section.find(GPI::CLU.parameters[0])
          section.update()
        end
      else
        # Update all sections
        Assets.update
        ObjectSpace.each_object(Section) do |s|
          s.update()
          if s.collection?
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
    Util.mkdir("_html/assets")
    Util.mkdir("_html/files")
  end

end

require 'zarchitect/assets.rb'
require 'zarchitect/audio.rb'
require 'zarchitect/category.rb'
require 'zarchitect/content.rb'
require 'zarchitect/file_manager.rb'
require 'zarchitect/image.rb'
require 'zarchitect/image_set.rb'
require 'zarchitect/index.rb'
require 'zarchitect/misc_file.rb'
require 'zarchitect/page.rb'
require 'zarchitect/rouge_html.rb'
require 'zarchitect/section.rb'
require 'zarchitect/util.rb'
require 'zarchitect/video.rb'
require 'zarchitect/zerb.rb'
