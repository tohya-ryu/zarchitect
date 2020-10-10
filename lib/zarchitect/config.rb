class Config
  
  # Constructor
  # requires yaml file
  def initialize(file)
    @file = file
    GPI.print "Initializing config from #{file}.", GPI::CLU.check_option('v')
    @hash = Hash.new
    begin
      YAML.load_stream(File.open(file) { |f| f.read }) do |doc|
        @hash = doc
        break
      end
    rescue StandardError
      GPI.print "Failed to load _config/_zarchitect.yaml."
      GPI.quit
    end
  end

  def validate_zrconf
    GPI.print "Validating #{@file}"
    unless @hash.has_key?("url")
      GPI.print "config key [url] missing in _config/_zarchitect.yaml."
      GPI.quit
    else
      unless @hash["url"].class == String
        GPI.print "Value of [url] is not a string."
        GPI.quit
      end
    end
    unless @hash.has_key?("site_name")
      GPI.print "config key [site_name] missing in _config/_zarchitect.yaml."
      GPI.quit
    else
      unless @hash["site_name"].class == String
        GPI.print "Value of key [site_name] is not a string."
        GPI.quit
      end
    end
    unless @hash.has_key?("thumbl")
      GPI.print "config key [thumbl] missing in _config/_zarchitect.yaml."
      GPI.quit
    else
      unless @hash["thumbl"].class == Array
        GPI.print "Value of key [thumbl] is not an Array."
        GPI.quit
      end
      unless @hash["thumbl"].count == 2
        GPI.print "Array [thumbl] requires two values."
        GPI.quit
      end
      unless @hash["thumbl"][0].class == Integer
        GPI.print "First value in [thumbl] ist not an integer."
        GPI.quit
      end
      unless @hash["thumbl"][1].class == Integer
        GPI.print "Second value in [thumbl] ist not an integer."
        GPI.quit
      end
    end
    unless @hash.has_key?("thumbs")
      GPI.print "config key [thumbs] missing in _config/_zarchitect.yaml."
      GPI.quit
    else
      unless @hash["thumbs"].class == Array
        GPI.print "Value of key [thumbs] is not an Array."
        GPI.quit
      end
      unless @hash["thumbs"].count == 2
        GPI.print "Array [thumbs] requires two values."
        GPI.quit
      end
      unless @hash["thumbs"][0].class == Integer
        GPI.print "First value in [thumbs] ist not an integer."
        GPI.quit
      end
      unless @hash["thumbs"][1].class == Integer
        GPI.print "Second value in [thumbs] ist not an integer."
        GPI.quit
      end
    end
    unless @hash.has_key?("rss_size")
      GPI.print "config key [rss_size] missing in _config/_zarchitect.yaml."
      GPI.quit
    else
      unless @hash["rss_size"].class == Integer
        GPI.print "Value of [rss_size] is not an integer."
        GPI.quit
      end
    end
    if @hash.has_key?("exclude_assets")
      unless @hash["exclude_assets"].class == Array
        GPI.print "Value of [rss_size] is not an array."
        GPI.quit
      end
    end
  end

end
