describe 'term_code' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.term_code }
  let(:transformer) {VstringTransformer.new}

  it 'parses terminology code' do
    expect(parser).to parse SNOMED_CODE
  end
end

class TermCodeTransformer < ::Parslet::Transform
  rule(value: simple(:value)) { value }
end

SNOMED_CODE = '[snomedct::163033001]'
