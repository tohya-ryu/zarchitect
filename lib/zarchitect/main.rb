class Main

  def initialize
  end

  def cmd_update
    #FileManager.clean if GPI::CLU.check_option('r')
    if GPI::CLU.check_option('r') # rebuild
      Dir[ File.join("_html", "**", "*") ].reverse.reject do |fullpath|
        if File.directory?(fullpath)
          GPI.print "deleting dir #{fullpath}"
          Dir.delete(fullpath)
          GPI.print "deleted dir #{fullpath}"
        else
          GPI.print "deleting file #{fullpath}"
          File.delete(fullpath)
          GPI.print "deleted file #{fullpath}"
        end
      end
    end
    Util.mkdir("_html/assets")
    Util.mkdir("_html/files")
    FileManager.run
    # prepare data for use in templates
    data = Hash.new
    Config.sections.each_key do |k|
      s = Section.new(k.to_s)
      s.create_html_dirs
      s.create_pages
      data[:"#{s.name}"] = s
    end
    ZERB.set_gdata(:sections, data)
    if GPI::CLU.parameters.length >= 1
      # update single section
      list = Array.new
      Config.sections.each_key do |k|
        list.push(k.to_s)
      end
      # check paramter for validity
      unless list.include?(GPI::CLU.parameters[0])
        GPI.print "Invalid parameter to command #{GPI::CLU.command}"
        GPI.print "Valid parameters:"
        list.each do |i|
          GPI.print "- #{i}"
        end
        GPI.quit
      end
      if GPI::CLU.parameters.length == 2
        # check if ARGV[2] is valid ID
        # update single post
        Assets.update
        section = Section.find(GPI::CLU.parameters[0])
        section.update(GPI::CLU.parameters[1])
      else
        # update all new posts
        Assets.update
        section = Section.find(GPI::CLU.parameters[0])
        section.update()
      end
    else
      # Update all sections
      Assets.update
      ObjectSpace.each_object(Section) do |s|
        s.update()
        if s.collection?
          # consider section index
        else
          # no section index
        end
      end
    end
    # update Index
  end

  def cmd_new
    section = GPI::CLU.parameters[0]
    unless Config.sections.has_key? (:"#{section}")
      GPI.print "Error: missing config entry for section #{section}"
      GPI.quit
    end
    s = Section.new(section)
    t = Time.now.to_i
    id = t.to_s(16)
    idrec = Array.new
    Util.mkdir("_build")
    mdpath = File.join(Util.path_to_data, "post.md.erb")
    idlistfile = File.open(File.join("_build", "idlist.txt"), "a+")
    idlist = idlistfile.read
    idlist.each_line { |l| idrec.push l.strip }
    idlistfile.write(id + "\n")
    idlistfile.close
    # validate id
    i = 1
    while idrec.include?(id) do
      id = (t+i).to_s(16).upcase
      i += 1
    end
    # get filename and setup necessary directories
    Util.mkdir(section)
    if GPI::CLU.parameters.size > 2
      title = GPI::CLU.parameters[2]
      title = Main.escape_title(title).downcase
      Util.mkdir(File.join(section, GPI::CLU.parameters[1]))
      filename = File.join(section, GPI::CLU.parameters[1],
                           "#{id}-#{title}.md")
      Util.mkdir(File.join(section, GPI::CLU.parameters[1]))
    else
      title = GPI::CLU.parameters[1]
      title = Main.escape_title(title).downcase
      filename = File.join(section, "#{id}-#{title}.md")
    end
    # write file
    a = ZERB.new(mdpath)
    a.set_data(:title, GPI::CLU.parameters[2])
    a.set_data(:date, "# fixme #{Time.now}")
    a.set_data(:author, Config.admin)
    a.set_data(:id, id)
    a.prepare
    a.render
    str = a.output
    GPI.print "writing #{filename}"
    if File.exist?(filename)
      GPI.print "Error: #{filename} already exists!"
      GPI.quit
    end
    File.open(filename, "w") { |f| f.write(str) }
    GPI.print "successfuly created #{filename}"
  end

  private

  def self.escape_title(str)
    i = 0
    str.each_char do |c|
      str[i] = "" unless c.match? /[a-zA-Z0-9-_]/
      i += 1
    end
    str
  end

end
