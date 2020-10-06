require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

class RougeHTML < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet
  def block_code(code, language)
    line = code.lines.first
    ar = line.split ':'
    code = code.lines.to_a[1..-1].join

    # add highlighting
    str = Rouge.highlight(code, ar[1].chomp, 'html')

    # add line numbers
    code2 = ""
    i = 1
    str.each_line do |l|
      j = "#{i}"
      if j.length == 1
        j.prepend("00")
      elsif j.length == 2
        j.prepend("0")
      end
      code2 << "<span style='user-select:none;-moz-user-select:none;'>" +
               "#{j}  </span>#{l}" 
      i += 1
    end

    # finalize
    code2.prepend("<pre><code class='highlight'>")
    code2 << "</code></pre>"

  end
end
