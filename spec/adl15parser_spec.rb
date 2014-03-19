describe OpenEHR::Parser::ADL15Parser do
  EXAMPLE = File.dirname(__FILE__) + '/examples/ADL15_tutorial/Archetypes/demographic/openEHR-DEMOGRAPHIC-ADDRESS.minimal.v1.adls'
  let(:parser) { OpenEHR::Parser::ADL15Parser.new(EXAMPLE) }

  it 'should be an instance of ADL15Parser' do
    expect(parser).to be_an_instance_of OpenEHR::Parser::ADL15Parser
  end

  context 'parsed archetype instance' do
    let(:archetype) { parser.parse }

    it 'ADL version equals 1.5' do
      expect(archetype.adl_version).to eq '1.5'
    end
  end
end
