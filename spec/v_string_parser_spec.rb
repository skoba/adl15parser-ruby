describe 'v_string' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.v_string }

  it 'matches in double quatation' do
    expect(parser).to parse VSTRING
  end

  it 'escapes backslashed "' do
    expect(parser).to parse VSTRING_WITH_ESCAPE
  end

  it 'does not parse lacked double quatation' do
    expect(parser).not_to parse NOT_CLOSED
  end

  it 'parses multi line string' do
    expect(parser).to parse MULTILINE.chomp
  end
end

class VstringTransformer < ::Parslet::Transform
  rule(v_string: simple(:v_string)) { v_string.to_s }
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
