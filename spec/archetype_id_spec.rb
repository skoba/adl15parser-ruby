describe 'archetype_id' do
  SIMPLE_ID = 'openEHR-DEMOGRAPHIC-ADDRESS.basic.v1'
  COMPLEX_ID = 'openehr-TEST_PKG-WHOLE.parent_with_uid_and_other_metadata.v1.0.0'
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.archetype_id }

  it 'parses archetype_id' do
    expect(parser).to parse SIMPLE_ID
  end

  it 'parsers complex_id' do
    expect(parser).to parse COMPLEX_ID
  end
end
