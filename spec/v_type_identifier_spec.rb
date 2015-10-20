describe 'v_type_identifier' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.v_type_identifier }
  let(:transformer) { VTypeIdentifierTransformer.new }

  it 'parse valid AttributeIdentifier' do
    expect(parser).to parse TYPE_IDENTIFIER
  end

  it 'transforms the parsed result' do
    result = transformer.apply(parser.parse TYPE_IDENTIFIER)
    expect(result).to eq TYPE_IDENTIFIER
  end
end

class VTypeIdentifierTransformer < ::Parslet::Transform
  rule(value: simple(:value)) { value }
end

TYPE_IDENTIFIER = 'OBSERVATION'.freeze
