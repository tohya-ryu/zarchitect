module Command

  class Update < Zarchitect

    def initialize
      Zarchitect.rebuild if GPI::CLU.check_option('r')
      Zarchitect.setup_html_tree
    end

    def run
    end

    private

  end

end
