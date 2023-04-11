module CMD

  class Sitemap < Zarchitect

    def initialize
      Zarchitect.sconf.each { |s| Zarchitect.add_section(s) }
      if GPI::CLU.check_option('v')
        SitemapGenerator.verbose = true
        SitemapGenerator::Sitemap.verbose = true
      else
        SitemapGenerator.verbose = false
        SitemapGenerator::Sitemap.verbose = false
      end
      SitemapGenerator::Sitemap.default_host = Zarchitect.conf.url
      SitemapGenerator::Sitemap.create_index = :auto
      SitemapGenerator::Sitemap.public_path = Zarchitect::HTMLDIR
    end

    def run
      reset_sitemap
      build_sitemap
    end

    private

    def reset_sitemap
      Dir.glob(File.join(HTMLDIR,"sitemap*.xml.gz")) do |path|
        if GPI::CLU.check_option('v')
          GPI.print "Attempting to remove '#{path}'"
        end
        File.delete(path)
        GPI.print "Removed '#{path}'" if GPI::CLU.check_option('v')
      end
    end

    def build_sitemap
      SitemapGenerator::Sitemap.create do 
        Zarchitect.sections.each do |section|
          # skip sections not meant to be included in sitemap
          if section.conf.has_option?("sitemap")
            next if section.conf.sitemap == 'exclude'
          end
          # set priority and changefrequency values
          post_prio = 1.0
          post_changefreq = 'monthly'
          index_prio = 0.5
          index_changefreq = 'weekly'
          if section.conf.has_option?("sm_post_prio")
            post_prio = section.conf.sm_post_prio
          elsif Zarchitect.conf.has_option?("sm_post_prio")
            post_prio = Zarchitect.conf.sm_post_prio
          end
          if section.conf.has_option?("sm_post_changefreq")
            post_changefreq = section.conf.sm_post_changefreq
          elsif Zarchitect.conf.has_option?("sm_post_changefreq")
            post_changefreq = Zarchitect.conf.sm_post_changefreq
          end
          if section.conf.has_option?("sm_index_prio")
            index_prio = section.conf.sm_index_prio
          elsif Zarchitect.conf.has_option?("sm_index_prio")
            index_prio = Zarchitect.conf.sm_index_prio
          end
          if section.conf.has_option?("sm_index_changefreq")
            index_changefreq = section.conf.sm_index_changefreq
          elsif Zarchitect.conf.has_option?("sm_index_changefreq")
            index_changefreq = Zarchitect.conf.sm_index_changefreq
          end

          # add section indices
          if section.index
            section.index.pages.each do |index|
              add index.url, :changefreq => index_changefreq,
                :lastmod => File.mtime(index.path).strftime("%FT%T%:z"),
                :priority => index_prio
            end
          end
          # add category and tag indices
          if section.conf.collection && section.conf.categorize
            section.categories.each do |cat|
              cat.index.pages.each do |index|
                add index.url, :changefreq => index_changefreq,
                  :lastmod => File.mtime(index.path).strftime("%FT%T%:z"),
                  :priority => index_prio
              end
              if cat.tags
                cat.tags.each do |tag|
                  tag.index.pages.each do |index|
                    add index.url, :changefreq => index_changefreq,
                      :lastmod => File.mtime(index.path).strftime("%FT%T%:z"),
                      :priority => index_prio
                  end
                end
              end
            end
          end
          # add posts and section contents
          section.posts.each do |post|
            # skip posts not meant to be included
            if post.conf.has_option?("sitemap")
              next if post.conf.sitemap == 'exclude'
            end
            prio = nil
            changefreq = nil
            if post.conf.has_option?("sm_prio")
              prio = post.conf.sm_prio
            else
              prio = post_prio
            end
            if post.conf.has_option?("sm_changefreq")
              changefreq = post.conf.sm_changefreq
            else
              changefreq = post_changefreq
            end
            add post.url, :changefreq => changefreq, 
              :lastmod => File.mtime(post.source_path).strftime("%FT%T%:z"),
              :priority => prio
          end
        end
      end
    end

  end

end
