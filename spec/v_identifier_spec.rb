describe 'v_identifier' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.v_identifier }
  let(:transformer) { VIdentifierTransformer.new }

  it 'parses identifier' do
    expect(parser).to parse IDENTIFIER
  end

  it 'transforms result to string' do
    result = transformer.apply(parser.parse IDENTIFIER)
    expect(result).to eq IDENTIFIER
  end

end

class VIdentifierTransformer < ::Parslet::Transform
  rule(value: simple(:x)) { x }
end

IDENTIFIER = "ABC10000"
