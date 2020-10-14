module Command

  class Update < Zarchitect

    def initialize
      rebuild if GPI::CLU.check_option('r')
      setup_htmldir
    end

    def run
    end

    private

    def rebuild
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

    def setup_htmldir
      Util.mkdir("_html")
      Util.mkdir("_html/assets")
      Util.mkdir("_html/files")
      Util.mkdir("_build/debug") if GPI::CLU.check_option('d')
    end

  end

end
