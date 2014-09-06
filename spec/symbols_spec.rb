describe 'Symbols' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new }

  it 'matches sym_matches' do
    expect(parser.sym_matches).to parse 'matches '
  end
end

