describe 'archetype_id' do
  SIMPLE_ID = 'openEHR-DEMOGRAPHIC-ADDRESS.basic.v1'
  COMPLEX_ID = 'openehr-TEST_PKG-WHOLE.parent_with_uid_and_other_metadata.v1.0.0'
  RC_ID = 'openEHR-EHR-OBSERVATION.no_ns_inherit_ns.v2.8.0-rc57'
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.archetype_id }

  it 'parses archetype_id' do
    expect(parser).to parse SIMPLE_ID
  end

  it 'parses complex_id' do
    expect(parser).to parse COMPLEX_ID
  end

  it 'parses id with rc' do
    expect(parser).to parse RC_ID
  end
end
