module CMD

  class Update < Zarchitect

    def initialize
      @sections = Hash.new
      Zarchitect.rebuild if GPI::CLU.check_option('r')
      Zarchitect.setup_html_tree
      @assets = Assets.new
      @assets.cpdirs
      SCSS.run
      @files = FileManager.new
      @files.run
    end

    def run
      Zarchitect.sconf.each do |s|
        @sections[s.key] = Section.new(s)
      end
    end

    private

  end

end
