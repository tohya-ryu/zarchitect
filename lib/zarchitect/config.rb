class Config
  
  # Constructor
  # requires yaml file
  def initialize(file, key)
    @file = file
    GPI.print "Initializing config from #{file}.", GPI::CLU.check_option('v')
    @hash = Hash.new
    begin
      YAML.load_stream(File.open(file) { |f| f.read }) do |doc|
        #key = file.sub(File.extname(file), '').sub('_config/', '')
        #@hash[:key] = doc
        @hash = doc
        break
      end
    rescue StandardError
      GPI.print "Failed to load #{@file}."
      GPI.quit
    end
    @hash["key"] = key
    unless @file == "_config/_index.yaml"
      @hash["index"] = false
    else
      @hash["index"] = true
    end
    instance_eval {
      @hash.each_key do |k|
        define_singleton_method k do
          @hash[k]
        end
      end
    }
  end

  def has_option?(str)
    @hash.has_key?(str)
  end

  def read(key)
    if has_option?(key)
      @hash[key] 
    else
      GPI.print "Option #{key} missing in  config #{@file}."
      GPI.quit
    end
  end

  def validate
    GPI.print "Validating #{@file}."
    if @hash.has_key?("sort_type")
      unless ["alphanum", "date"].include?(@hash["sort_type"])
        GPI.print "Value of [sort_type] has to be 'date' or 'alphanum'."
        GPI.quit
      end
    else
      @hash["sort_type"] = "alphanum"
    end
    if @hash.has_key?("sort_order")
      unless ["default", "reverse"].include?(@hash["sort_order"])
        GPI.print "Value of [sort_order] has to be 'default' or 'reverse'."
        GPI.quit
      end
    else
      @hash["sort_order"] = "default"
    end
    unless @hash.has_key?("collection") 
      @hash["collection"] = false
    end
    if @hash["collection"] == true
      unless @hash.has_key?("index_layout")
        GPI.print "The [index_layout] option is required."
        GPI.quit
      else
        unless @hash["index_layout"].class == String
          GPI.print "Value of [index_layout] is not a string."
          GPI.quit
        end
      end
      unless @hash.has_key?("index_view")
        GPI.print "The [index_view] option is required."
        GPI.quit
      else
        unless @hash["index_view"].class == String
          GPI.print "Value of [index_view] is not a string."
          GPI.quit
        end
      end
      unless @file == "_config/_index.yaml"
        if @hash.has_key?("directory")
          unless @hash["directory"].class == String
            GPI.print "Value of [directory] has to be a string."
            GPI.quit
          end
        else
          GPI.print "Collections require the [directory] option."
          GPI.quit
        end
      end
      unless @hash.has_key?("categorize")
        GPI.print ("Collections require the [categorize] option.")
        GPI.quit
      end
      if @hash["categorize"] == true
        unless @hash.has_key?("tags")
          GPI.print ("Collections with categories require the [tags] option.")
          GPI.quit
        end
        unless @hash.has_key?("categories")
          GPI.print ("Collections with categories require" +
                     " the [categories] option.")
          GPI.quit
        else
          unless @hash["categories"].class == Hash
            GPI.print "Categories option is required to be a hash."
            GPI.quit
          else
            @hash["categories"].each do |k,v|
              if k.class == String && v.class == String
                if k.match(/\A[a-zA-Z0-9_-]*\z/).nil?
                  GPI.print "Invalid category key: #{k}. Only alphanumerics,"+
                    " dashes and underscores allowed!"
                    GPI.quit
                end
              else
                GPI.print "Keys and values of [categories] option have to be" +
                  " strings."
                GPI.quit
              end
            end
          end
        end
      end
    else
      @hash["categorize"] = false
      @hash["tags"] = false
    end
    unless @file == "_config/_index.yaml"
      if @hash.has_key?("name")
        unless @hash["name"].class == String
          GPI.print "[name] is required to be a string."
          GPI.quit
        end
      else
        GPI.print "[name] option is missing."
        GPI.quit
      end
    else
      if @hash.has_key?("uses") 
        unless @hash["uses"].class == String
          GPI.print "[uses] should be a comma separated list of sections."
          GPI.quit
        end
      end
    end
    unless @hash.has_key?("layout")
      GPI.print "The [layout] option is required."
      GPI.quit
    else
      unless @hash["layout"].class == String
        GPI.print "Value of [layout] is not a string."
        GPI.quit
      end
    end
    unless @hash.has_key?("view")
      GPI.print "The [view] option is required."
      GPI.quit
    else
      unless @hash["view"].class == String
        GPI.print "Value of [view] is not a string."
        GPI.quit
      end
    end
    if @hash.has_key?("paginate")
      unless @hash["paginate"].class == Integer
        GPI.print "Value of [paginate] can only be an integer."
        GPI.quit
      else
        if @hash["paginate"] < 0
          GPI.print "Valur of [paginate] has to be equal or greater than 0."
          GPI.quit
        end
      end
    else
      if @hash["collection"] == true
        GPI.print "[paginate] option is required for collections."
        GPI.quit
      end
    end
  end

  def validate_zrconf
    GPI.print "Validating #{@file}."
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
