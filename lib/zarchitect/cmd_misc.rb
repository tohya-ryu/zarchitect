module CMD

  class Misc < Zarchitect

    def self.setup
      Zarchitect.setup_html_tree
      Util.mkdir(FILEDIR)
      Util.mkdir(ASSETDIR)
      Util.mkdir(LAYOUTDIR)
      Util.mkdir(CONFIGDIR)

      a = File.join(Util.path_to_data, "_zarchitect.yaml")
      b = File.join(CONFIGDIR, "_zarchitect.yaml")

      File.copy(File.join(Util.path_to_data, "_zarchitect.yaml"), File.join(
        CONFIGDIR, "_zarchitect.yaml"))
    end

    def self.update_files
      @files = FileManager.new
      @files.run
    end

    def self.update_assets
      Util.mkdir(File.join(HTMLDIR, ASSETSDIR))
      SCSS.run
      @assets = Assets.new
      @assets.cpdirs
      @assets.update
    end

  end

end
