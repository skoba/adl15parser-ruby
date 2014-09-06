describe 'c_attribute grammar' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new }

  it 'c_attr_head' do
    expect(parser.c_attr_head).to parse C_ATTR_HEAD
  end

  it 'c_attribute' do
    expect(parser.c_attribute).to parse C_ATTRIBUTE
  end
end

C_ATTR_HEAD = 'details'

C_ATTRIBUTE = <<DOC
details matches {
	ITEM_TREE[at0001] occurrences matches {0..1} matches { 
		items matches {
			CLUSTER[at0002] matches { 
				items matches {
					ELEMENT[at0003] matches { 
						value matches {
							DV_TEXT matches {*} 
						}
					}
				}
			}
		}
	}
}
DOC
