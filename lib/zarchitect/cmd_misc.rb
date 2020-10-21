module CMD

  class Misc < Zarchitect

    def self.setup
      Zarchitect.setup_html_tree
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
