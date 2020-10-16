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
    GPI::CLU.use_command("u", [0], "rvqd")
    GPI::CLU.use_command("update", [0], "rvqd")

    GPI::CLU.use_command("ua", [0], "")
    GPI::CLU.use_command("update-assets", [0], "")

    GPI::CLU.use_command("new", 2..3, "")
    #app_command(0..2, "r") # appname = command.name
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
    load_conf
    case GPI::CLU.command
    when "new" # create md file for new web page   
      cmd = Command::New.new
      cmd.run
    when "update","u"
      cmd = CMD::Update.new
      cmd.run
    when "sync"
      # draw data from mastodon / twitter api
    when "ua"
      m.cmd_update_assets
    end
  end

  def rss
    @@rss
  end

  private

  def self.rebuild
    # delete all contents of _html
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

  def self.setup_html_tree
    Util.mkdir("_html")
    Util.mkdir("_html/assets")
    Util.mkdir("_html/files")
    Util.mkdir("_build/debug") if GPI::CLU.check_option('d')
  end

  def load_conf
    @@zr_config = Config.new("_config/_zarchitect.yaml", "configuration")
    @@zr_config.validate_zrconf
    @@index_config = Config.new("_config/_index.yaml", "index")
    @@index_config.validate
    @@sec_config = Array.new
    Dir.files("_config").each do |f|
      next if f[0] == "." # don't read swap files
      next if f == "_zarchitect.yaml"
      next if f == "_index.yaml"
      n = f.sub(".yaml", "")
      @@sec_config.push Config.new("_config/#{f}", n)
      @@sec_config.last.validate
    end
  end

  def Zarchitect.conf
    @@zr_config
  end

  def Zarchitect.iconf
    @@index_config
  end
  
  def Zarchitect.sconf
    @@sec_config
  end
end

require 'zarchitect/assets.rb'
require 'zarchitect/audio.rb'
require 'zarchitect/category.rb'
require 'zarchitect/config.rb'
require 'zarchitect/content.rb'
require 'zarchitect/file_manager.rb'
require 'zarchitect/image.rb'
require 'zarchitect/image_set.rb'
require 'zarchitect/index.rb'
require 'zarchitect/cmd_update.rb'
#require 'zarchitect/cmd_new.rb'
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
