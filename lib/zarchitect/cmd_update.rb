module CMD

  class Update < Zarchitect

    def initialize
      if GPI::CLU.check_option('r')
        Zarchitect.rebuild
        Zarchitect.setup_html_tree
        @assets = Assets.new
        @assets.cpdirs
        @assets.update
        SCSS.run
      end
      @files = FileManager.new
      @files.run
    end

    def run
      Zarchitect.sconf.each { |s| Zarchitect.add_section(s) }
      Zarchitect.add_section(Zarchitect.iconf)
      Zarchitect.sections.sort_by! { |v| v.conf.id }
      Zarchitect.sections.push Zarchitect.sections.shift
      Zarchitect.sections.each do |s|
        s.build_html
        s.write_html
      end
      rss.build
    end

    private

  end

end
