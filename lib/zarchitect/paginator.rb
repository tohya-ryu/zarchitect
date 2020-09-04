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
    @curr_page += 1
    if @curr_page > @page_number
      GPI.print "Error: paginator went above total page number."
      GPI.quit
    end
  end

end
