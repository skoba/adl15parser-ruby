describe 'v_uri' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.v_uri }
  let(:transformer) {VUriTransformer.new}

  it 'parsis terminology code' do
    expect(parser).to parse URI
  end
end

class VUriTransformer < ::Parslet::Transform
  rule(value: simple(:value)) { value }
end

URI = "http://openEHR.org/home"
