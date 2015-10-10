describe 'v_dotted_numeric' do
  let(:parser) {OpenEHR::Parser::ADL15Parslet.new.v_dotted_numeric}

  it 'parses classical archetype id' do
    expect(parser).to parse ARCHETYPE_ID
  end
end

ARCHETYPE_ID = '1.2.3'
