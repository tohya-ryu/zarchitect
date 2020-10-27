module CMD

  class New < Zarchitect
  end

  def run
    Zarchitect.sconf.each { |s| Zarchitect.add_section(s) }
    @section = Zarchitect.section(GPI::CLU.parameters[0])
    if @section.nil?
      GPI.print "Error: Section with key #{GPI::CLU.parameters[0]} does not" +
        " exist."
      GPI.quit
    end
    if GPI::CLU.parameters.size > 2
      @category = nil
      @category = @section.categories.select { |c|
        c.key == GPI::CLU.parameters[1] }
      if @category.nil?
        GPI.print "Error: category with key #{GPI::CLU.parameters[1]} " +
          "not found in #{@section}."
        GPI.quit
      end
      @title = GPI::CLU.parameters[2]
      @dir = File.join(@section.key, @category.key)
    else
      @title = GPI::CLU.parameters[1]
      @dir = File.join(@section.key)
    end
    @id = get_id
    # write file
    a = ZERB.new(File.join(Util.path_to_data, "post.md.erb"))
    a.set_data("title", @title)
    a.set_data("date", Time.now)
    a.set_data("author", Zarchitect.conf.admin)
    a.set_data("id", @id)
    a.set_data("category", @category)
    a.prepare
    a.render
    str = a.output
    @dest = File.join(@dir, "#{@id}-#{@title}.md")
    GPI.print "Writing #{@dest}"
    if File.exist?(@dest)
      GPI.print "Error: File at #{@dest} already exists!"
      GPI.quit
    end
    File.open(@dest, "w") { |f| f.write(str) }
    GPI.print "Wrote #{@dest}"
  end

  private

  def get_id
    t = Time.now.to_i
    id = t.to_s(16).downcase

    idlist = Array.new
    Zarchitect.sections.each do |s|
      s.all_posts.each do |p|
        idlist.push p.conf.id if p.conf.has_option?("id")
      end
    end

    i = 1
    while idlist.include?(id) do
      id = (t+i).to_s(16).upcase
      i += 1
    end
    id
  end

end
