describe 'archetype marker' do
  ARCHETYPE_MARKER = 'archetype'

  let(:parser) {OpenEHR::Parser::ADL15Parslet.new}

  it 'parses and matches archetype marker' do
    expect(parser.archetype_marker).to parse ARCHETYPE_MARKER
  end

  it 'also pasers irregular cases' do
    expect(parser.archetype_marker).to parse 'ArCheType'
  end
  
end
