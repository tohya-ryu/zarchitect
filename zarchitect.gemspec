Gem::Specification.new do |s|
  s.name = 'zarchitect'
  s.version = '0.0.0'
  s.executables << 'zarchitect'
  s.date = '2020-09-25'
  s.summary = 'Static website generator'
  s.description = 'Yet another static website generator'
  s.authors = ["tohya ryu"]
  s.email = 'ryu@tohya.net'
  s.files = ["lib/zarchitect.rb",
             "lib/zarchitect/assets.rb",
             "lib/zarchitect/audio.rb",
             "lib/zarchitect/category.rb",
             "lib/zarchitect/cmd_misc.rb",
             "lib/zarchitect/cmd_new.rb",
             "lib/zarchitect/cmd_update.rb",
             "lib/zarchitect/config.rb",
             "lib/zarchitect/content.rb",
             "lib/zarchitect/file_manager.rb",
             "lib/zarchitect/html.rb",
             "lib/zarchitect/htmltable.rb",
             "lib/zarchitect/image_set.rb",
             "lib/zarchitect/image.rb",
             "lib/zarchitect/index.rb",
             "lib/zarchitect/misc_file.rb",
             "lib/zarchitect/post.rb",
             "lib/zarchitect/paginator.rb",
             "lib/zarchitect/rss.rb",
             "lib/zarchitect/rouge_html.rb",
             "lib/zarchitect/scss.rb",
             "lib/zarchitect/section.rb",
             "lib/zarchitect/tag.rb",
             "lib/zarchitect/util.rb",
             "lib/zarchitect/video.rb",
             "lib/zarchitect/zerb.rb",
             "data/post.md.erb"]
  s.homepage = 'https://github.com/tohya-ryu/zarchitect'
  s.license = 'GPL-3.0'
end
