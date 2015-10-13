describe 'v_real' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.v_real }
  let(:transformer) {VRealTransformer.new}

  it 'parses REAL number' do
    expect(parser).to parse REAL
  end

  it 'transforms result to real number' do
    result = transformer.apply(parser.parse REAL)
    expect(result).to eq REAL.to_f
  end
end

class VRealTransformer < ::Parslet::Transform
  rule(value: simple(:x)) { x.to_f }
end

REAL = "1234.56"
