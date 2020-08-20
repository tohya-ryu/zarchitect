xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @data[:site_name]
    xml.description @data[:meta_desc]
    xml.link root_url
                      
    for post in @posts
      xml.item do
        xml.title post.title
        xml.description post.content
        xml.pubDate post.published_date.to_s(:rfc822)
        xml.link article_url(post)
        xml.guid article_url(post)
      end
    end
  end
end
