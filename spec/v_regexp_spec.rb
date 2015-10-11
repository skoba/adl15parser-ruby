describe 'v_regexp' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.v_regexp }
  let(:transformer) { VRegexpTransformer.new }
  
  context 'matches regular expression' do
    it 'parses regular expression' do
      expect(parser).to parse REGULAR_EXPRESSION
    end
  end

  context 'this is also regular expression' do
    it 'is also parses other regular expression' do
      expect(parser).to parse OTHER_REGULAR_EXPRESSION
    end
  end

  it 'escaped / is not a separator' do
    expect(parser).not_to parse THIS_IS_BROKEN
  end

  it 'transform to extract regular expression' do
    result = transformer.apply parser.parse(REGULAR_EXPRESSION)
    expect(result).to eq "this|that|something else"
  end
end

class VRegexpTransformer < ::Parslet::Transform
  rule(value: simple(:value)) { value }
end



REGULAR_EXPRESSION = '/this|that|something else/'

OTHER_REGULAR_EXPRESSION = '/cardio.*\/vascular.*/'

THIS_IS_BROKEN = '/broken\/'
