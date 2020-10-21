class Tag < Zarchitect

  def initialize(str)
    @name = str
    @key = hash(str)
  end

  private

  def hash(str)
    str2 = String.new
    str.each_char do |c|
      str2 << c.ord.to_s
    end
    str2 = str2.to_i
    str2.to_s(16).downcase
  end





end
