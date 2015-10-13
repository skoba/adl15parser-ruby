describe 'v_uri' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.v_uri }
  let(:transformer) {VUriTransformer.new}

  it 'parses URI' do
    expect(parser).to parse URI
  end

  it 'transforms result to URI chars' do
    result = transformer.apply(parser.parse URI)
    expect(result).to eq URI
  end
end

class VUriTransformer < ::Parslet::Transform
  rule(value: simple(:x)) { x.to_s }
end

URI = "http://openEHR.org/home"
