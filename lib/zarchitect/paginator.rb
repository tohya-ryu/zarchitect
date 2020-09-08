class Paginator
  attr_reader :page_number, :curr_page, :range, :max

  MAX = 15

  def initialize(base_url, page_number)
    @base_url    = base_url
    @page_number = page_number
    @curr_page   = 1
    @range       = Array.new
    @max         = MAX
  end

  def url(n)
    n = "" if n == 1
    File.join(@base_url, "index#{n}.html")
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
    default = [ 1, 2, @curr_page, @page_number-1, @page_number ]
    sector = (@max -1) / 2 # 7 if max 15
    @range.clear



    if @page_number <= @max
      i = 1
      while i <= @page_number
        @range.push i
      end
    else
      b = @curr_page - sector # begin
      b = 3 if start < 3
      e = start + (@max-1)-4 # end
      e = page_number-2 if e > @page_number-2

      @range.push 1, 2
      @range.push 0 if start > 3 # gap!
      i = b
      while i <= e do
        @range.push i
        i -= 1
      end
      @range.push 0 if e < @page_number-2 # gap!
      @range.push @page_number-1, @page_number
    end

  end

end
