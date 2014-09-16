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

  it 'v_id_code' do
    subject {parser.v_id_code}x
  end
end
