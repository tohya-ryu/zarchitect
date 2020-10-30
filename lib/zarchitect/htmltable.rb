class HTMLTable

  def initialize
    @lines = Array.new
    @starts_at = nil
    @ends_at = nil
    @coln = 0
    @html = "<table>"
    @rows = Array.new
  end

  def process
    @coln -= 1 # table syntax expects one more pipes than columns

    @lines.each_with_index do |l,i|
      ar = l.split('|', -1)
      ar.shift
      ar.pop
      ar2 = get_colspans(ar)
      ar.map! { |a| a.strip }
      if ar[0].count("-") == ar[0].length
        # header previous row is header
        @rows.last.set_header
      else
        # row
        @rows.push HTMLTableRow.new(ar,ar2) 
      end
    end

    @rows.each do |r|
      r.process
      @html << r.html
    end


    @html << "</table>"
  end

  def add_line(l)
    @coln = l.count('|') if l.count('|') > @coln
    @lines.push l
  end

  def print
    @lines.each { |l| p l }
  end

  def starts_at(x)
    @starts_at = x
  end

  def ends_at(x)
    @ends_at = x
  end

  def replace(ar)
    ar[@starts_at] = @html
    ar.each_with_index do |x,i|
      ar[i] = nil if i > @starts_at && i <= @ends_at
    end
    ar
  end

  private

  def get_colspans(ar)
    cspans = Array.new
    ar.each_with_index do |str,i|
      if str == ""
        cspans.push 0
      else
        cspans.push cspancnt(1, ar,i)
      end
    end
    cspans
  end

  def cspancnt(c, ar,i)
    if i+1 < ar.length
      if ar[i+1] == ""
        c += 1
        c = cspancnt(c, ar, i+1)
      end
    end
    c
  end

end

class HTMLTableRow

  def initialize(ar,ar2)
    @contents = ar
    @colspans = ar2
    @headerf = false
    @columns = Array.new
    @html = "<tr>"
  end

  def set_header
    @headerf = true
  end

  def html
    @html
  end

  def process
    @contents.each_with_index do |str,i|
      next if @colspans[i] == 0
      @columns.push HTMLTableCell.new(str,@colspans[i], @headerf)
    end
    @columns.each do |c|
      c.process
      @html << c.html
    end

    @html << "</tr>"
  end

end

class HTMLTableCell

  def initialize(str,n,h)
    @content = str
    @colspan = n
    @headerf = h
    @html = String.new
    if @headerf
      @html << "<th colspan=\"#{@colspan}\">"
    else
      @html << "<td colspan=\"#{@colspan}\">"
    end
  end

  def process
    @html << @content
    if @headerf
      @html << "</th>"
    else
      @html << "</td>"
    end
  end

  def html
    @html
  end

end
