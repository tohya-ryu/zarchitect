module CMD

  class Update < Zarchitect

    def initialize
      @sections = Hash.new
      Zarchitect.rebuild if GPI::CLU.check_option('r')
      Zarchitect.setup_html_tree
      Assets.cpdirs
      SCSS.run
      FileManager.run
    end

    def run
      Zarchitect.sconf.each do |s|
        @sections[s.key] = s
      end
      p @sections
    end

    private

  end

end
