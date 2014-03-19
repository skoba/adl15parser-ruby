describe OpenEHR::Parser::ADL15Parser do
  let(:parser) { OpenEHR::Parser::ADL15Parser.new('examples/ADL15_tutorial/Archetypes/demographic/openEHR-DEMOGRAPHIC-ADDRESS.minimal.v1.adls') }

  it 'should be an instance of ADL15Parser' do
    expect(parser).to be_an_instance_of OpenEHR::Parser::ADL15Parser
  end
end
