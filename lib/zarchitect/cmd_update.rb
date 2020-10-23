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
      index = Section.new(Zarchitect.iconf)
      Zarchitect.sconf.each do |s|
        @sections[s.key].build_html
        #@sections[s.key].write_html
      end
      index.build_html
      #index.write_html
    end

    private

  end

end
