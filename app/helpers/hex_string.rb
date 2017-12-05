class HexString < String
  def initialize(string)
    super(string.each_char.select { |x| x.match(/[0-9]|[a-f]/i) }.join(''))
  end
end
