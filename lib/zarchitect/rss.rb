class RSS

  def initialize
    @items = Array.new
  end

  def try_item(page)
    return if page.draft
    if @items.count < Config.rss_size # simply add page to rss items
      @items.push RSSItem.new(page)
    else # check if it's more recent than the oldest item in the feed
      if page.date > @items.last.date
        @items.pop
        @items.push RSSItem.new(page)
      end
    end
    @items.sort_by! { |i| i.date }.reverse!
  end


end


class RSSItem

  def initialize(page)
    @date = page.date
  end

end
