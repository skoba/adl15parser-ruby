describe 'v_character' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.v_character }
  let(:transformer) { VCharacterTransformer.new }

  it 'parse valid character' do
    expect(parser).to parse VALID_CHAR
  end

  it 'does not parse line feed' do
    expect(parser).not_to parse LINEFEED
  end

  it 'does not parse double quatation' do
    expect(parser).not_to parse DOUBLE_QUATATION
  end

  # it 'does not parse backslash' do
  #   expect(parser).not_to parse BACKSLASH
  # end

  it 'transform valid character' do
    result = transformer.apply(parser.parse VALID_CHAR)
    expect(result).to eq VALID_CHAR
  end
end

class VCharacterTransformer < ::Parslet::Transform
  rule(value: simple(:value)) { value }
end

VALID_CHAR = 'a'
LINEFEED = "\n"
DOUBLE_QUATATION = '"'
BACKSLASH = "\\"
