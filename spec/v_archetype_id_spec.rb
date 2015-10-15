describe 'v_archetype_id' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.v_archetype_id }
  let(:transformer) { VArchetypeIDTransformer.new }

  it 'parses conventional identifier' do
    expect(parser).to parse CONVENTIONAL_ARCHETYPEID
  end

  it 'parses namespaced identifier, too' do
    expect(parser).to parse NAMESPACED_ARCHETYPEID
  end

  it 'transforms result to string' do
    result = transformer.apply(parser.parse NAMESPACED_ARCHETYPEID)
    expect(result).to eq NAMESPACED_ARCHETYPEID
  end

end

class VArchetypeIDTransformer < ::Parslet::Transform
  rule(value: simple(:x)) { x }
end

CONVENTIONAL_ARCHETYPEID = "openEHR-EHR-OBSERVATION.blood_pressure.v1"
NAMESPACED_ARCHETYPEID = "org.openEHR::openEHR-EHR-OBSERVATION.blood_pressure.v1"


