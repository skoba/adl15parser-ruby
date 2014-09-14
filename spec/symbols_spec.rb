describe 'Symbols' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new }

  describe 'sym_matches' do
    let(:sym_matches) { parser.sym_matches }

    it 'matches matches' do
      expect(sym_matches).to parse 'matches '
    end

    it 'does not match matchess' do
      expect(sym_matches).not_to parse 'matchess'
    end
  end

  describe 'sym_archetype' do
    let(:sym_archetype) { parser.sym_archetype }

    it 'matches archetype' do
      expect(sym_archetype).to parse 'ArCheType'
    end

    it 'does not match archytype' do
      expect(sym_archetype).not_to parse 'archytype'
    end
  end

  describe 'sym_template' do
    let(:sym_template) { parser.sym_template }

    it 'matches template' do
      expect(sym_template).to parse 'TEMPLATE'
    end

    it 'does not match tenplate' do
      expect(sym_template).not_to parse 'tenplate'
    end
  end

  describe 'sym_template_overlay' do
    let(:sym_template_overlay) {parser.sym_template_overlay}

    it 'matches template overlay' do
      expect(sym_template_overlay).to parse 'template_overlay-- comment'
    end

    it 'dones not match template_over_lay' do
      expect(sym_template_overlay).not_to parse 'template_over_lay'
    end
  end

  describe 'sym_operational_template' do
    let(:sym_operational_template) {parser.sym_operational_template}

    it 'matches operational_template' do
      expect(sym_operational_template).to parse 'operational_template'
    end

    it 'does not match operational template' do
      expect(sym_operational_template).not_to parse 'operational template'
    end
  end

  describe 'sym_adl_version' do
    let(:sym_adl_version) {parser.sym_adl_version}

    it 'matches adl_version' do
      expect(sym_adl_version).to parse "ADL_VERSION\n\n"
    end

    it 'does not match adl_verison' do
      expect(sym_adl_version).not_to parse 'adl_verison'
    end
  end

  it 'matches controlled' do
    expect(parser.sym_is_controlled).to parse 'controlled'
  end

  it 'matches generated' do
    expect(parser.sym_is_generated).to parse 'generated'
  end

  it 'matches specialised' do
    expect(parser.sym_specialize).to parse 'specialised'
  end

  it 'matches'
end
