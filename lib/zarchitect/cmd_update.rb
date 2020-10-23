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
        @files = FileManager.new
        @files.run
      end
    end

    def run
      Zarchitect.sconf.each do |s|
        Zarchitect.add_section(s)
        #@sections[s.key] = Section.new(s)
      end
      Zarchitect.add_section(Zarchitect.iconf)
      #index = Section.new(Zarchitect.iconf)
      Zarchitect.sections.sort_by! { |v| v.conf.id }
      Zarchitect.sections.push Zarchitect.sections.shift
      Zarchitect.sections.each do |s|
        s.build_html
        s.write_html
        #@sections[s.key].build_html
        #@sections[s.key].write_html
      end
      #index.build_html
      #index.write_html
    end

    private

  end

end
