Gem::Specification.new do |s|
  s.name = 'zarchitect'
  s.version = '0.0.0'
  s.executables << 'zarchitect'
  s.date = '2020-07-29'
  s.summary = 'Static website generator'
  s.description = 'Yet another static website generator'
  s.authors = ["tohya ryu"]
  s.email = 'ryu@tohya.net'
  s.files = ["lib/zarchitect.rb",
             "lib/zarchitect/index.rb",
             "lib/zarchitect/page.rb",
             "lib/zarchitect/section.rb"]
  s.homepage = 'https://github.com/tohya-ryu/zarchitect'
  s.license = 'GPL-3.0-only'
end
