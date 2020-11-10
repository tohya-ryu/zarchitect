require 'gpi'
require 'yaml'
require 'erb'
require 'sanitize'
require 'rss'
require 'nokogiri'

class Zarchitect

  HTMLDIR = "_html"
  BUILDIR = "_build"
  FILEDIR = "_files"
  ASSETDIR = "_assets"
  DRAFTDIR = "_drafts"
  LAYOUTDIR = "_layouts"
  CONFIGDIR = "_config"

  FILESDIR = "files"
  SHARESDIR = "share" # directory under _files that doesn't have thumbnails
  ASSETSDIR = "assets"
  DEBUGSDIR = "debug"

  def initialize
    @@sections = Array.new
    GPI.app_name = "zarchitect"
    GPI.extend(:dir)
    GPI.extend(:file)
    GPI.extend(:hash)
    GPI.extend(:numeric)
    GPI.extend(:string)
    GPI::CLU.init
    # Command name | range of parameter num | options
    GPI::CLU.use_command("u", [0], "rvqdD")
    GPI::CLU.use_command("update", [0], "rvqdD")

    GPI::CLU.use_command("ua", [0], "v")
    GPI::CLU.use_command("update-assets", [0], "v")

    GPI::CLU.use_command("uf", [0], "v")
    GPI::CLU.use_command("update-files", [0], "v")
    GPI::CLU.use_command("setup", [0], "v")

    GPI::CLU.use_command("new", 2..3, "v")
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
    case GPI::CLU.command
    when "new" # create md file for new web page   
      load_conf
      cmd = CMD::New.new
      cmd.run
    when "update","u"
      load_conf
      cmd = CMD::Update.new
      cmd.run
    when "sync"
      # draw data from mastodon / twitter api
    when "update-assets","ua"
      load_conf
      CMD::Misc.update_assets
    when "update-files","uf"
      load_conf
      CMD::Misc.update_files
    when "setup"
      CMD::Misc.setup
    end
  end

  def rss
    @@rss
  end

  private

  def self.rebuild
    # delete all contents of _html
    Dir[ File.join(HTMLDIR, "**", "*") ].reverse.reject do |fullpath|
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
    Util.mkdir(HTMLDIR)
    Util.mkdir(File.join(HTMLDIR, ASSETSDIR))
    Util.mkdir(File.join(HTMLDIR, FILESDIR))
    Util.mkdir(File.join(BUILDDIR, DEBUGSDIR)) if GPI::CLU.check_option('d')
  end

  def load_conf
    @@zr_config = Config.new("_config/_zarchitect.yaml", "configuration")
    @@zr_config.validate_zrconf
    @@zr_config.setup
    @@index_config = Config.new("_config/_index.yaml", "index")
    @@index_config.validate
    @@index_config.setup
    @@sec_config = Array.new
    Dir.files("_config").each do |f|
      next if f[0] == "." # don't read swap files
      next if f == "_zarchitect.yaml"
      next if f == "_index.yaml"
      n = f.sub(".yaml", "")
      @@sec_config.push Config.new("_config/#{f}", n)
      @@sec_config.last.validate
      @@sec_config.last.setup
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

  def Zarchitect.add_section(conf)
    #@@sections[conf.key] = Section.new(conf)
    @@sections.push Section.new(conf)
  end

  def Zarchitect.sections
    @@sections
  end

  def Zarchitect.section(key)
    @@sections.each do |s|
      return s if s.key == key
    end
    nil
  end

end

require 'zarchitect/assets.rb'
require 'zarchitect/audio.rb'
require 'zarchitect/category.rb'
require 'zarchitect/config.rb'
require 'zarchitect/content.rb'
require 'zarchitect/file_manager.rb'
require 'zarchitect/html.rb'
require 'zarchitect/htmltable.rb'
require 'zarchitect/image.rb'
require 'zarchitect/image_set.rb'
require 'zarchitect/index.rb'
require 'zarchitect/cmd_misc.rb'
require 'zarchitect/cmd_new.rb'
require 'zarchitect/cmd_update.rb'
require 'zarchitect/misc_file.rb'
require 'zarchitect/post.rb'
require 'zarchitect/paginator.rb'
require 'zarchitect/rouge_html.rb'
require 'zarchitect/rss.rb'
require 'zarchitect/scss.rb'
require 'zarchitect/section.rb'
require 'zarchitect/tag.rb'
require 'zarchitect/util.rb'
require 'zarchitect/video.rb'
require 'zarchitect/zerb.rb'
