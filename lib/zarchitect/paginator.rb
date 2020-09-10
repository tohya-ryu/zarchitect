class Paginator
  attr_reader :page_number, :curr_page, :range, :max

  MAX = 15

  def initialize(base_url, page_number)
    @base_url    = base_url    # used to construct urls to pages
    @page_number = page_number # number of pages in total
    @curr_page   = 1           # current page
    @range       = Array.new   # numbers of pages in pagination
    @max         = MAX         # how many pages to be shown in pagination
  end

  def url(n)
    if n == 1
      return File.join(@base_url, "index.html")
    else
      return File.join(@base_url, "index-#{n}.html")
    end
  end

  def next
    if @curr_page < @page_number
      @curr_page += 1
      update_range
    else
      GPI.print "Warning: paginator attempted to exceed total page number",
        GPI::CLU.check_option('v')
    end
  end

  private

  def update_range
    # creates array of page numbers to use as pagination links
    default = [ 1, 2, @curr_page, @page_number-1, @page_number ]
    sector = (@max -1) / 2 # 7 if max 15
    @range.clear



    if @page_number <= @max
      i = 1
      while i <= @page_number
        @range.push i
        i += 1
      end
    else
      b = @curr_page - sector # begin
      b = 3 if b < 3
      e = b + (@max-1)-4 # end
      e = page_number-2 if e > @page_number-2

      @range.push 1, 2
      @range.push 0 if b > 3 # gap!
      i = b
      while i <= e do
        @range.push i
        i += 1
      end
      @range.push 0 if e < @page_number-2 # gap!
      @range.push @page_number-1, @page_number
    end

  end

end
