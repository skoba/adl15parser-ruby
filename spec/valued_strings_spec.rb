describe 'valued strings' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new }

  describe 'v_uri' do
    subject {parser.v_uri}

    it {is_expected.to parse 'http://openehr.org/id/433'}
    it {is_expected.not_to parse 'zzz::xxx/bb'}
  end

  describe 'v_root_id_coode' do
    subject {parser.v_root_id_code}

    it {is_expected.to parse '[id1]'}
    it {is_expected.to parse '[id1.1.1.1]'}
    it {is_expected.not_to parse '[id11]'}
  end

  describe 'v_id_code' do
    subject {parser.v_id_code}

    it {is_expected.to parse '[id123]'}
    it {is_expected.not_to parse '[at0001'}
  end

  describe 'v_qualified_term_code_ref' do
    subject {parser.v_qualified_term_code_ref}

    it {is_expected.to parse '[123::456]'}
    it {is_expected.not_to parse '[]'}
    it {is_expected.not_to parse '[123::  45 6]'}
  end

  describe 'v_local_term_code_ref' do
    subject {parser.v_local_}
  end
end
