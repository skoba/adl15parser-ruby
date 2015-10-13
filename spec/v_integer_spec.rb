describe 'v_integer' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.v_integer }
  let(:transformer) {VIntegerTransformer.new}

  it 'parses URI' do
    expect(parser).to parse INTEGER
  end

  it 'transforms result to URI chars' do
    result = transformer.apply(parser.parse INTEGER)
    expect(result).to eq INTEGER.to_i
  end
end

class VIntegerTransformer < ::Parslet::Transform
  rule(value: simple(:x)) { x.to_i }
end

INTEGER = "123456"
