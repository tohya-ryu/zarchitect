module CMD

  class Update < Zarchitect

    def initialize
      @sections = Hash.new
      if GPI::CLU.check_option('r')
        Zarchitect.rebuild
        Zarchitect.setup_html_tree
        @assets = Assets.new
        @assets.cpdirs
        SCSS.run
        @files = FileManager.new
        @files.run
      end
    end

    def run
      Zarchitect.sconf.each do |s|
        @sections[s.key] = Section.new(s)
      end
    end

    private

  end

end
