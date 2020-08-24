class FileManager

  FROM = "_files" # dir where raw files reside
  TO   = "_html/files"

  def self.run
    # iterate FROM 
    Dir[ File.join(FROM, '**', '*') ].reject do |fullpath|
      path = fullpath[(FROM.length)..-1]
      realpath = File.join(TO, path) # path of new dir/symlink
      
      # dir handling
      Util.mkdir(realpath) if File.directory?(fullpath)
      next if File.directory?(fullpath)
      # file handling
      if Image.is_valid?(fullpath)
      elsif Audio.is_valid?(fullpath)
      elsif Video.is_valid?(fullpath)
      else
      end

    end
    # create dir copies in TO
    # create symlinks in TO pointing to FROM | rsync can copy files behind link
  end

  def iterate
  end

end

class FileObject
end
