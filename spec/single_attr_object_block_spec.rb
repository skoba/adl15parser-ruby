describe 'single attr object block parsere' do
  let(:parser) {
    OpenEHR::Parser::ADL15Parslet.new.keyed_object }

  it 'parse single_attr_object_block' do
    expect(parser).to parse SINGLE_ATTR_OBJECT_BLOCK
  end

end


SINGLE_ATTR_OBJECT_BLOCK = <<DOC
["de"] = <
	language = <[ISO_639-1::en]>
	purpose = <"Minimalist address archetype, illustrating archetype structure">
	keywords = <"demographic", "address">
	copyright = <"copyright (c) 2012 openEHR foundation">
         >
DOC
