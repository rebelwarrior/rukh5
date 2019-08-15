# HexString class is only createded with valid hex characters.
class HexString < String
  def initialize(string)
    super(string.to_str.each_char.select { |chr| chr.match(/[0-9]|[a-f]/i) }.join(''))
  end
end
