describe 'Symbols' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new }

  describe 'sym_archetype' do
    subject { parser.sym_archetype }

    it {is_expected.to parse 'ArCheType'}
    it {is_expected.not_to parse 'archytype'}
  end

  describe 'sym_template' do
    subject { parser.sym_template }

    it {is_expected.to parse 'TEMPLATE'}

    it {is_expected.not_to parse 'tenplate'}
  end

  describe 'sym_template_overlay' do
    subject {parser.sym_template_overlay}

    it {is_expected.to parse 'template_overlay-- comment'}
    it {is_expected.not_to parse 'template_over_lay'}
  end

  describe 'sym_operational_template' do
    subject {parser.sym_operational_template}

    it {is_expected.to parse 'operational_template'}
    it {is_expected.not_to parse 'operational template'}
  end

  describe 'sym_adl_version' do
    subject {parser.sym_adl_version}

    it {is_expected.to parse "ADL_VERSION\n\n"}
    it {is_expected.not_to parse 'adl_verison'}
  end

  describe 'sym_is_controled' do
    subject {parser.sym_is_controlled}

    it {is_expected.to parse 'controlled' }
    it {is_expected.not_to parse 'is_controlled'}
  end

  describe 'sym_is_generated' do
    subject {parser.sym_is_generated}

    it {is_expected.to parse 'generated'}
    it {is_expected.not_to parse 'is_generated'}
  end

  describe 'sym_specialize' do
    subject {parser.sym_specialize}

v    it {is_expected.to parse 'specialized'}
    it {is_expected.to parse 'specialised'}
    it {is_expected.not_to parse 'specialize'}
  end

  describe 'sym_concept' do
    subject {parser.sym_concept}

    it {is_expected.to parse 'concept'}
    it {is_expected.not_to parse 'context'}
  end

  describe 'sym_definition' do
    subject {parser.sym_definition}

    it {is_expected.to parse 'DefinItion'}
    it {is_expected.not_to parse 'Definitions'}
  end

  describe 'sym_language' do
    subject {parser.sym_language}

    it {is_expected.to parse 'language'}
    it {is_expected.not_to parse 'other_language'}
  end

  describe 'sym_description' do
    subject {parser.sym_description}

    it {is_expected.to parse 'description'}
    it {is_expected.not_to parse "definition"}
  end

  describe 'sym_invariant' do
    subject {parser.sym_invariant}

    it {is_expected.to parse 'invariant'}
    it {is_expected.not_to parse 'invariance'}
  end

  describe 'sym_terminology' do
    subject {parser.sym_terminology}

    it {is_expected.to parse "TERMINOLOGY\t\t\t"}
    it {is_expected.not_to parse 'ONTOLOGY'}
  end

  describe 'sym_ontology' do
    subject {parser.sym_ontology}

    it {is_expected.to parse 'ONTOLOGY   '}
    it {is_expected.not_to parse 'TERMINOLOGY'}
  end

  describe 'sym_rules' do
    subject {parser.sym_rules}

    it {is_expected.to parse 'rules   '}
    it {is_expected.not_to parse 'rurles'}
  end

  describe 'sym_annotations' do
    subject {parser.sym_annotations}

    it {is_expected.to parse 'annotations'}
    it {is_expected.not_to parse 'anotation'}
  end

  describe 'sym_component_terminologies' do
    subject {parser.sym_component_terminologies}

    it {is_expected.to parse 'component_terminologies'}
    it {is_expected.not_to parse 'component terminology'}
  end

  describe 'sym_uid' do
    subject {parser.sym_uid}

    it {is_expected.to parse 'uid  '}
    it {is_expected.not_to parse 'uuid'}
  end

  describe 'sym_start_dblock' do
    subject {parser.sym_start_dblock}

    it {is_expected.to parse "< \n\n --\n\n"}
    it {is_expected.not_to parse "{"}
  end

  describe 'sym_end_dblock' do
    subject {parser.sym_end_dblock}

    it {is_expected.to parse '>'}
    it {is_expected.not_to parse '}'}
  end

  describe 'sym_interval_delim' do
    subject {parser.sym_interval_delim}

    it {is_expected.to parse '|   '}
    it {is_expected.not_to parse ';'}
  end

  describe 'sym_eq' do
    subject {parser.sym_eq}
      
    it {is_expected.to parse '= '}
    it {is_expected.not_to parse '>'}
  end

  describe 'sym_ge' do
    subject {parser.sym_ge}

    it {is_expected.to parse '>='}
    it {is_expected.not_to parse '=>'}
  end

  describe 'sym_le' do
    subject {parser.sym_le}

    it {is_expected.to parse '<='}
    it {is_expected.not_to parse '=<'}
  end

  describe 'sym_lt' do
    subject {parser.sym_lt}

    it {is_expected.to parse '<'}
    it {is_expected.not_to parse '>'}
  end

  describe 'sym_gt' do
    subject {parser.sym_gt}

    it {is_expected.to parse '>'}
    it {is_expected.not_to parse '='}
  end

  describe 'sym_ellipsis' do
    subject {parser.sym_ellipsis}

    it {is_expected.to parse '..'}
    it {is_expected.not_to parse '...'}
  end

  describe 'sym_list_continue' do
    subject {parser.sym_list_continue}

    it {is_expected.to parse '...'}
    it {is_expected.not_to parse '..'}
  end

  describe 'sym_true' do
    subject {parser.sym_true}

    it {is_expected.to parse 'TRUE'}
    it {is_expected.not_to parse 'Truth'}
  end

  describe 'sym_false' do
    subject {parser.sym_false}

    it {is_expected.to parse 'false'}
    it {is_expected.not_to parse 'falsy'}
  end

  describe 'cADL symbols' do
    describe 'sym_start_cblock' do
      subject {parser.sym_start_cblock}

      it {is_expected.to parse "{ --- comments \n\n"}
      it {is_expected.not_to parse "{ --- comments \n\n terminology"}
    end

    describe 'sym_end_cblock' do
      subject {parser.sym_end_cblock}

      it {is_expected.to parse "}"}
      it {is_expected.not_to parse "}\n\n NEXT sec"}
    end

    describe 'sym_matches' do
      subject { parser.sym_matches }

      it {is_expected.to parse 'matches '}
      it {is_expected.not_to parse 'matchess'}
    end
    
    describe 'sym_existence' do
      subject {parser.sym_existence}

      it {is_expected.to parse 'existence'}
      it {is_expected.not_to parse 'exists'}
    end

    describe 'sym_occurrences' do
      subject {parser.sym_occurrences}

      it {is_expected.to parse "occurrences\n"}
      it {is_expected.not_to parse "occurrences\t next"}
    end

    describe 'sym_cardinality' do
      subject {parser.sym_cardinality}

      it {is_expected.to parse 'cardinality '}
      it {is_expected.not_to parse 'cardinality other facts'}
    end

    describe 'sym_use_node' do
      subject {parser.sym_use_node}

      it {is_expected.to parse 'use_node'}
      it {is_expected.not_to parse 'use_node and'}
    end

    describe 'sym_allow_archetype' do
      subject {parser.sym_allow_archetype}

      it {is_expected.to parse 'allow_archetype '}
      it {is_expected.to parse 'use_archetype'}
      it {is_expected.not_to parse 'archetype'}
      it {is_expected.not_to parse "allow_archetype*"}
    end

    describe 'sym_after' do
      subject {parser.sym_after}

      it {is_expected.to parse 'after '}
      it {is_expected.not_to parse "after\nsecond"}
    end

    describe 'sym_before' do
      subject {parser.sym_before}

      it {is_expected.to parse "before\t"}
      it {is_expected.to parse "before--"}
      it {is_expected.to parse "before--comment comment\n"}
      it {is_expected.not_to parse "before--comment\n other"}
    end

    describe 'sym_closed' do
      subject {parser.sym_closed}

      it {is_expected.to parse "CLosEd\r"}
      it {is_expected.not_to parse "CLosEd\rnext"}
    end
  end
end
