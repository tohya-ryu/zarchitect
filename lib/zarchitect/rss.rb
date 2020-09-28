class ZRSS

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

  def build
    rss = RSS::Maker.make("atom") do |maker|
      maker.channel.title = Config.site_name
      maker.channel.author = Config.admin
      maker.channel.updated = Time.now.to_s
      maker.channel.about = Config.site_description
      maker.channel.link = Config.url

      @items.each do |item|
        maker.items.new_item do |rss_item|
          rss_item.title = item.title
          rss_item.pubDate = item.date
          rss_item.description = item.description
          rss_item.link = item.link
          #rss_item.guid = item.guid
        end
      end
    end

    #write rss
    File.open("_html/feed.rss", "w") { |f| f.write(rss) }
  end


end


class RSSItem
  attr_reader :date, :title, :description, :link, :guid

  def initialize(page)
    @date = page.date
    @title = page.name
    @description = page.description
    @link = page.url
    @guid = page.url
  end

end
