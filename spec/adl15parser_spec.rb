describe OpenEHR::Parser::ADL15Parser do
  EXAMPLE = File.join(File.dirname(__FILE__), 'examples/ADL15_tutorial/Archetypes/demographic/openEHR-DEMOGRAPHIC-ADDRESS.minimal.v1.adls')
  let(:parser) { OpenEHR::Parser::ADL15Parser.new(EXAMPLE) }

  it 'should be an instance of ADL15Parser' do
pending
    expect(parser).to be_an_instance_of OpenEHR::Parser::ADL15Parser
  end

  context 'parsed archetype instance' do
    let(:archetype) { parser.parse }

    it 'should not raise error' do
pending
      expect { archetype }.not_to raise_error
    end

    it 'ADL version equals 1.5' do
pending
      expect(archetype.adl_version).to eq '1.5'
    end

    it 'archetype_id is openEHR-DEMOGRAPHIC-ADDRESS.minimal.v1' do
pending
      expect(archetype.archetype_id).to eq 'openEHR-DEMOGRAPHIC-ADDRESS.minimal.v1'
    end

    it 'language is en' do
pending
      expect(archetype.language.code_string).to eq 'en'
    end

    it 'terminology id is ISO_639-1' do
pending
      expect(archetype.language.terminology_id.value).to eq 'ISO_639-1'
    end
    
  end
end
