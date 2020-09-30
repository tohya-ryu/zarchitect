require 'gpi'
require 'yaml'
require 'erb'
require 'sanitize'
require 'rss'
require 'nokogiri'

class Zarchitect

  def initialize
    GPI.app_name = "zarchitect"
    GPI.extend(:dir)
    GPI.extend(:file)
    GPI.extend(:hash)
    GPI.extend(:numeric)
    GPI.extend(:string)
    GPI::CLU.init
    # Command name | range of parameter num | options
    GPI::CLU.use_command("update", 0..2, "rvqd")
    GPI::CLU.use_command("new", 2..3, "")
    #app_command(0..2, "r") # appname = command.name
    GPI::CLU.use_command("sync", 1, "") # paramter=section to sync
    GPI::CLU.process_args
    @@rss = ZRSS.new
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
    conf.to_module("Config")
    m = Main.new
    case GPI::CLU.command
    when 'new' # create md file for new web page   
      m.cmd_new
    when 'update'
      m.cmd_update
    when 'sync'
      # draw data from mastodon / twitter api
    end
  end

  def rss
    @@rss
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
require 'zarchitect/main.rb'
require 'zarchitect/misc_file.rb'
require 'zarchitect/page.rb'
require 'zarchitect/paginator.rb'
require 'zarchitect/rouge_html.rb'
require 'zarchitect/rss.rb'
require 'zarchitect/scss.rb'
require 'zarchitect/section.rb'
require 'zarchitect/util.rb'
require 'zarchitect/video.rb'
require 'zarchitect/zerb.rb'
