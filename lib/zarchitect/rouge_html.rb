require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

class RougeHTML < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet
  def block_code(code, language)
    line = code.lines.first
    ar = line.split ':'
    code = code.lines.to_a[1..-1].join
    str = "<pre><code class='highlight'>"
    str << Rouge.highlight(code, ar[1].chomp, 'html')
    str << "</code></pre>"
  end
end
