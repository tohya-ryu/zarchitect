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
    GPI.extend(:string)
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
    conf = Hash.new
    #@@options = Hash.new { rebuild: nil }
    begin
      File.open('_config.yaml') { |f| conf = YAML.load(f) }
    rescue StandardError
      GPI.print "Could not load config.yaml"
      GPI.quit
    end
    prepwork
    conf.to_module("Config")
    case GPI::CLU.command
    when 'update'
      Filemanager.run()
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
    unless Dir.exist?("_html/assets")
      GPI.print "Missing directory _html/assets", GPI::CLU.check_option('v')
      GPI.print "Creating directory _html/assets", GPI::CLU.check_option('v')
      Dir.mkdir(File.join(Dir.getwd, "_html", "assets"))
      GPI.print "Created directory _html/assets", GPI::CLU.check_option('v')
    end
    unless Dir.exist?("_html/files")
      GPI.print "Missing directory _html/files", GPI::CLU.check_option('v')
      GPI.print "Creating directory _html/files", GPI::CLU.check_option('v')
      Dir.mkdir(File.join(Dir.getwd, "_html", "files"))
      GPI.print "Created directory _html/files", GPI::CLU.check_option('v')
    end
  end

end

require 'zarchitect/assets.rb'
require 'zarchitect/category.rb'
require 'zarchitect/content.rb'
require 'zarchitect/file.rb'
require 'zarchitect/image.rb'
require 'zarchitect/index.rb'
require 'zarchitect/page.rb'
require 'zarchitect/rouge_html.rb'
require 'zarchitect/section.rb'
require 'zarchitect/zerb.rb'
