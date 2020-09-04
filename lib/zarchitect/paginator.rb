class Paginator
  attr_reader :page_number, :curr_page

  def initialize(base_url, page_number)
    @base_url = base_url
    @page_number = page_number
    @curr_page = 1
  end

  def url(n)
    n = "" if n == 1
    File.join(@base_url, "index#{n}.html")
  end

  def next
    if @curr_page < @page_number
      @curr_page += 1
    else
      GPI.print "Warning: paginator attempted to exceed total page number",
        GPI::CLU.check_option('v')
    end
  end

end
