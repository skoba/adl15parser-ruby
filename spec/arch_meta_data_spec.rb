require 'rspec'
require 'parslet/rig/rspec'
require 'adl15parser'
require 'parslet/convenience'

MINIMUM_META_DATA = <<DOC
(adl_version=1.5)
DOC

ARCH_META_DATA = <<DOC
(adl_version=1.5.1; uid=15E82D77-7DB7-4F70-8D8E-EED6FF241B2D; some_flag=true; some_key=some_value; another_key=another_value)
DOC


describe 'archetype meta data' do
  let(:parser) {OpenEHR::Parser::ADL15Parslet.new }
  context 'minimum_meta_data' do
    it 'parse minimum meta data' do
      expect(parser.arch_meta_data).to parse MINIMUM_META_DATA
    end
  end

  context 'complexed meta data' do
    it 'parse complex meta data' do
      expect(parser.arch_meta_data).to parse ARCH_META_DATA
    end
  end
end


