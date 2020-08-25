class ImageSet
  attr_reader :orig, :thumbs, :thumbl
  #TODO abort on invalid filesize

  def initialize(path, fullpath, realpath)
    @thumbl = nil
    @thumbs = nil
    # path = /section/title/img.png
    # fullpath = _files/section/title/img.png
    # realpath = _html/files/section/title/img.png
    filename  = File.basename(path, ".*")
    extension = File.extname(path)
    realdir   = File.dirname(realpath)
    @orig = Image.new(realpath, false)

    # check if thumbnails exist
    # attempt to create them if not
    thumbs_path = "#{File.join(realdir, filename)}-thumbs#{extension}"
    thumbl_path = "#{File.join(realdir, filename)}-thumbl#{extension}"
    @orig.thumbs_f = File.exist?(thumbs_path)
    @orig.thumbl_f = File.exist?(thumbl_path)
    unless @orig.thumb_small?
      if @orig.larger_than_thumb_small?
        r = @orig.create_thumbnail(thumbs_path, Config.thumbs[0].to_i,
                                   Config.thumbs[1].to_i)
        @orig.thumbs_f = r
      end
    end
    unless @orig.thumb_large?
      if @orig.larger_than_thumb_small?
        r = @orig.create_thumbnail(thumbl_path, Config.thumbl[0].to_i,
                                   Config.thumbl[1].to_i)
        @orig.thumbl_f = r
      end
    end
    # set thumbnails if created
    if @orig.thumb_small?
      @thumbs = Image.new(thumbs_path, true)
    end
    if @orig.thumb_large?
      @thumbl = Image.new(thumbl_path, true)
    end

  end

end
