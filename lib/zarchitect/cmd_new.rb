module CMD

  class New < Zarchitect

    def initialize
      Zarchitect.sconf.each { |s| Zarchitect.add_section(s) }
      @section = Zarchitect.section(GPI::CLU.parameters[0])
      if @section.nil?
        GPI.print "Error: Section with key #{GPI::CLU.parameters[0]} does " +
          "not exist."
        GPI.quit
      end
      @category = nil
      if GPI::CLU.parameters.size > 2
        @category = @section.find_category(GPI::CLU.parameters[1])
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
    end

    def run
      check_key
      @id = get_id
      # write file
      a = ZERB.new(File.join(Util.path_to_data, "post.md.erb"))
      data = Hash.new
      data["title"] = @title
      data["key"] = @title
      data["date"] = Time.now
      data["author"] = Zarchitect.conf.admin
      data["id"] = @id
      data["category"] = @category
      a.handle_data(data)
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

    def check_key
      duplicate_key = false
      context = ""
      unless @category.nil?
        @category.posts.each do |post|
          duplicate_key = true if @title == post.key
          context = "#{@section.key}/#{@category.key}"
        end
      else
        @section.posts.each do |post|
          duplicate_key = true if @title == post.key
          context = "#{@section.key}"
        end
      end
      if duplicate_key
        GPI.print "Error: key {#{@title}} already present in #{context}."
        GPI.quit
      end
    end

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
end
