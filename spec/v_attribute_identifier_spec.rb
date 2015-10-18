describe 'v_attribute_identifier' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.v_attribute_identifier }
  let(:transformer) { VAttributeIdentifierTransformer.new }

  it 'parse valid AttributeIdentifier' do
    expect(parser).to parse ATTRIBUTE_IDENTIFIER
  end

  it 'transforms the parsed result' do
    result = transformer.apply(parser.parse ATTRIBUTE_IDENTIFIER)
    expect(result).to eq ATTRIBUTE_IDENTIFIER
  end
end

class VAttributeIdentifierTransformer < ::Parslet::Transform
  rule(value: simple(:value)) { value }
end

ATTRIBUTE_IDENTIFIER = 'protocol'.freeze
