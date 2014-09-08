describe 'v_string' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.v_string }
  let(:transformer) {VstringTransformer.new}

  
  context 'matches characters in double quatation' do
    it 'parses V_STRING rule' do
      expect(parser).to parse VSTRING
    end

    it 'parse_tree transformed to string' do
      tree = parser.parse_with_debug VSTRING
      expect(transformer.apply tree).to eq VSTRING[1...-1]
    end
  end

  context 'escapes backslashed "' do
    it 'parses escaped double quatation' do
      expect(parser).to parse VSTRING_WITH_ESCAPE
    end

    it 'includes whole string' do
      tree = parser.parse_with_debug VSTRING_WITH_ESCAPE
      expect(transformer.apply tree).to eq VSTRING_WITH_ESCAPE[1...-1]
    end
  end

  context 'parses multi line string' do
    it 'parses multiline string' do
      expect(parser).to parse MULTILINE.chomp.chomp
    end

    it 'includes whole string' do
      tree = parser.parse_with_debug MULTILINE.chomp
      expect(transformer.apply tree).to eq MULTILINE[1...-2]
    end
  end

  it 'does not parse lacked double quatation' do
    expect(parser).not_to parse NOT_CLOSED
  end
end

class VstringTransformer < ::Parslet::Transform
  rule(value: simple(:value)) { value }
end


VSTRING = '"matches"'

VSTRING_WITH_ESCAPE = %q{"a\"x'c\\d"}

NOT_CLOSED = '"not closed double quatation'

MULTILINE =<<DOC
"LOREM
IPSUM
HOME TO
DO"
DOC
