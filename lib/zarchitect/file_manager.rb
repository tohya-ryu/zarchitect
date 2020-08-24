class FileManager

  FROM = "_files" # dir where raw files reside
  TO   = "_html/files"

  def self.run
    # iterate FROM 
    Dir[ File.join(FROM, '**', '*') ].reject { |p| p }
    # create dir copies in TO
    # create symlinks in TO pointing to FROM | rsync can copy files behind link
  end

  def iterate
  end

end

class FileObject
end
