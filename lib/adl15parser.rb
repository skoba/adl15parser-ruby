require 'openehr'
require 'parslet'

module OpenEHR
  module Parser
    class ADL15Parser < OpenEHR::Parser::Base
      def parse
        transformer.apply(parslet_engine.parse(filestream.read))
      end

      def filestream
        File.open(@filename, 'r:bom|utf-8')
      end

      def parslet_engine
        ADL15Parslet.new
      end

      def transformer
        ADL15Transformer.new
      end
    end

    class ArchMock
      attr_accessor :adl_version, :archetype_id

      def initialize(attribute = {})
        @adl_version = attribute[:adl_version]
        @archetype_id = attribute[:archetype_id]
      end
    end

    class ADL15Parslet < ::Parslet::Parser
      root :input

      rule(:input) { archetype } #| specialised_archetype | tempalate | template_overlay | operational_template }

      rule(:archetype) do
        archetype_marker >>
          arch_meta_data >>
          archetype_id >>
          arch_language >>
          any.repeat
      end

      rule(:archetype_marker) { sym_archetype >> spaces? }
      rule(:arch_meta_data) {str('(') >> arch_meta_data_items >> str(')') >> spaces? }
      rule(:arch_meta_data_items) { arch_meta_data_item.repeat(1) }
      rule(:arch_meta_data_item) { adl_version  }
      rule(:adl_version) { sym_adl_version >> sym_eq >> version_string.as(:adl_version) >> spaces? }
      rule(:archetype_id) { ((namestr >> (str('.') >> alphanum_str).repeat >> str('::')).maybe >> namestr >> str('-') >> alphanum_str >> str('-') >> namestr >> str('.') >> namestr >> (str('-') >> alphanum_str).repeat >> str('.v') >> match('[0-9]').repeat(1) >> ((str('.') >> match([0-9]).repeat(1)).repeat(0,2) >> (str('-rc') | str('+') | str('+') >> match([0-9]).repeat(1)).maybe).maybe).as(:archetype_id) >> spaces? }
      rule(:arch_language) { sym_language >> spaces.maybe >> v_odin_text }
      rule(:v_odin_text) { attr_vals | complex_object_block }
      rule(:object_block) { complex_object_block | primitive_object_block }
      rule(:complex_object_block) { single_attr_object_block | multiple_attr_object_block }
      rule(:single_attr_object_block) { type_identifier.maybe >> untyped_single_attr_object_block }
      rule(:multiple_attr_object_block) { type_identifier.maybe >> untyped_multiple_object_block }
      rule(:primitive_object_block) { }
      rule(:type_identifier) { str('(').maybe >> v_generic_type_identifier | v_type_identifier >> str(')').maybe >> spaces? }
      rule(:untyped_single_attr_object_block) { single_attr_object_complex_head >> attr_vals.maybe >> sym_end_dblock }
      rule(:single_attr_object_complex_head) { sym_start_dblock }
      rule(:untyped_multiype_attr_object_block) { multiple_attr_object_block_head }
      rule(:attr_vals) { attr_val >> (str(';').maybe >> spaces >> attr_val).repeat >> spaces? }
      rule(:attr_val) { attr_id >> sym_eq >> object_block >> spaces? }
      rule(:attr_id) { v_attribute_identifier >> spaces? }
      rule(:v_attribute_identifier) { match('[a-z]') >> idchar.repeat }
      rule(:v_generic_type_identifier) { match('[A-Z]') >> idchar.repeat >> str('<') >> match('[a-zA-Z0-9,_]').repeat(1) >> str('>') }
      rule(:v_type_identifier) { match('[A-Z]') >> idchar.repeat }
      rule(:idchar) { match '[a-zA-Z0-9_]'}
      rule(:version_string) { number >> str('.') >> number >> (str('.') >> number).maybe}
      rule(:spaces?) { spaces.maybe >> comment.maybe >> spaces.maybe }
      rule(:comment) { str('--') >> any.repeat >> str("\n") }
      rule(:spaces) { space.repeat }
#      rule(:space?) { space.maybe? }
      rule(:space) { match '\s' }
      rule(:namestr) {match(["a-zA-Z"]) >> match(['a-zA-Z0-9_']).repeat(1) }
      rule(:alphanum_str) { match('[a-zA-Z0-9_]').repeat(1) }
      rule(:number) {match '[0-9]'}
      rule(:sym_archetype) { (str('archetype') | str('ARCHETYPE')) >> spaces? }
      rule(:sym_adl_version) { str 'adl_version' }
      rule(:sym_language) { str 'language' }
      rule(:sym_start_dblock) {str '{'}
      rule(:sym_end_dblock) { str '}'}
      rule(:sym_eq) { str '=' }
    end

    class ADL15Transformer < ::Parslet::Transform
      rule(archetype_id: sequence(:archetype_id), adl_version: simple(:adl_version)) { ArchMock.new(adl_version: adl_version, archetype_id: archetype_id)} 
    end
  end
end
