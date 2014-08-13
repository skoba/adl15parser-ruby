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
      def stri(str)
        key_chars = str.split(//)
        key_chars.
          collect! { |char| match["#{char.upcase}#{char.downcase}"] }.
          reduce(:>>)
      end

      root :input

      rule(:input) { archetype } #| specialised_archetype | tempalate | template_overlay | operational_template }

      rule(:archetype) do
        archetype_marker >>
          arch_meta_data >>
          archetype_id >>
          arch_language >>
          arch_description >>
          arch_definition >>
          arch_rules >>
          arch_terminology >>
          arch_annotations
      end

      rule(:archetype_marker) {
        sym_archetype }

      rule(:archetype_id) {
        v_archetype_id.as(:archetype_id) >> spaces?}

      rule(:arch_meta_data) {
        str('-/-') |
        str('(') >> arch_meta_data_items >> str(')') >> spaces? }

      rule(:arch_meta_data_items) {
        arch_meta_data_item >> (str(';') >> arch_meta_data_item).repeat }

      rule(:arch_meta_data_item) {
        sym_adl_version >> sym_eq >> v_dotted_numeric.as(:adl_version) |
        # sym_uid >> sym_eq >> v_dotted_numeric |
        # sym_uid >> sym_eq >> v_value |
        sym_is_controlled |
        sym_is_generated |
        v_identifier >> sym_eq >> v_identifier |
        # v_identifier >> sym_eq >> v_value |
        v_identifier } #|
#        v_value }

      rule(:arch_specialisation) {
        sym_specialize >> v_archetype_id }

      rule(:arch_language) {
        sym_language >> v_odin_text }

      rule(:arch_description) {
        sym_description >> v_odin_text }

      rule(:arch_definition) {
        sym_definition >> v_odin_text }

      rule(:arch_rules) {
        str('-/-') |
        sym_rules >> v_rules_text }

      rule(:arch_terminology) {
        sym_terminology >> v_odin_text }

      rule(:arch_annotations) {
        str('-/-') |
        sym_annotations >> v_odintext }

      # ODIN
      rule(:v_odin_text) {
        attr_vals |
        complex_object_block }

      rule(:attr_vals) {
        attr_val >> (str(';').maybe >> spaces >> attr_val).repeat}

      rule(:attr_val) {
        attr_id >> sym_eq >> object_block >> spaces? }

      rule(:object_block) {
        complex_object_block |
        primitive_object_block |
        object_reference_block |
        sym_start_dblock >> sym_end_dblock}

      rule(:complex_object_block) {
        single_attr_object_block |
        container_attr_object_block }

      rule(:single_attr_object_block) {
        type_identifier.maybe >> untyped_single_attr_object_block }

      # rule(:multiple_attr_object_block) { type_identifier.maybe >> untyped_multiple_attr_object_block }
      rule(:primitive_object_block) {
        untyped_single_attr_object_block |
        (type_identifier >> untyped_single_primitive_object_block) }

      rule(:type_identifier) {
        str('(').maybe >> v_generic_type_identifier |
        v_type_identifier >> str(')').maybe >> spaces? }

      # rule(:untyped_single_attr_object_block) { single_attr_object_complex_head >> attr_vals.maybe >> sym_end_dblock }
      rule(:single_attr_object_complex_head) { sym_start_dblock }

      # rule(:untyped_multiple_attr_object_block) { multiple_attr_object_block_head }
      # rule(:multiple_attr_object_block_head){}

      rule(:attr_id) {
        v_attribute_identifier >> spaces? }

      # Definitions
      rule(:alphanum) {
        match '[a-zA-Z0-9]' }

      rule(:idchar) {
        match '[a-zA-Z0-9_]'}

      rule(:namechar) {
        match '[a-zA-Z0-9._\-]' }

      rule(:namechar_space) {
        match '[a-zA-Z0-9._\- ]' }

      rule(:namechar_paren) {
        match '[a-zA-Z0-9._\-()]' }

      rule(:namestr) {
        match("[a-zA-Z]") >> match('[a-zA-Z0-9_]').repeat(1) }

      #rule(:id_code_leader)

      rule(:alphanum_str) { match('[a-zA-Z0-9_]').repeat(1) }

      rule(:number) {match '[0-9]'}
      rule(:v_dotted_numeric) {
        number >> str('.') >> number >> (str('.') >> number).maybe}

      rule(:space) { match '\s' }

      # rule(:space?) { space.maybe? }

      rule(:spaces) { space.repeat }

      rule(:comment) {
        str('--') >> any.repeat >> str("\n") }

      rule(:spaces?) {
        spaces >> comment.maybe >> spaces.maybe }

      # Symbols
      rule(:sym_archetype) {
        stri('archetype') >> spaces? }

      rule(:sym_template) {
        stri('template') >> spaces? }

      rule(:sym_template_overlay) {
        stri('template_overlay') >> spaces? }

      rule(:sym_operational_template) {
        stri('operational_template') >> spaces? }

      rule(:sym_adl_version) {
        stri('adl_version') >> spaces? }

      rule(:sym_is_controlled) {
        stri('controlled') >> spaces? }

      rule(:sym_is_generated) {
        stri('generated') >> spaces? }

      rule(:sym_specialize) {
        (stri('specialised') | stri('specialized')) >> spaces? }

      rule(:concept) {
        stri('concept') >> spaces? }

      rule(:sym_definition) {
        stri('definition') >> spaces? }

      rule(:sym_language) {
        stri('language') >> spaces? }

      rule(:sym_description){
        stri('description') >> spaces? }

      rule(:sym_invariant) {
        stri('invariant') >> spaces? }

      rule(:sym_terminology) {
        stri('terminology') >> spaces? }

      rule(:sym_annotations) {
        stri('annotations') >> spaces? }

      rule(:sym_component_terminologies) {
        stri('component_terminologies') >> spaces? }

      rule(:sym_start_dblock) {
        str('<') >> spaces? }

      rule(:sym_end_dblock) {
        str('>') >> spaces? }

      rule(:sym_eq) {
        str('=') >> spaces? }

      rule(:sym_ge) {
        str('>=') >> spaces? }

      rule(:sym_le) {
        str('<=') >> spaces? }

      rule(:sym_lt) { sym_start_dblock }

      rule(:sym_gt) { sym_end_dblock }

      rule(:sym_ellipsis) {
        str('..') >> spaces? }

      rule(:sym_list_continue) {
        str('...') >> spaces? }

      rule(:sym_true) {
        stri('true') >> spaces? }

      rule(:sym_false) {
        stri('false') >> spaces? }

      # valued strings
      rule(:v_uri) {
        match('[a-z]').repeat(1) >> str('://') >>
        match('[^<>|\\{}^~"\[\])]').repeat >> spaces? }

      rule(:v_qualified_term_code_ref) {
        str('[') >> namechar_paren.repeat(1) >>
        str('::') >> namechar.repeat(1) >> str(']') >> spaces? }

      rule(:err_v_qualified_term_code_ref) {
        str('[') >> namechare_paren.repeat(1) >>
        str('::') >> namechar_space.repeat(1)>> str(']') >> spaces? }

      rule(:v_local_term_code_ref) {
        str('[') >> match('a(c|t)[0-9.]+') >> str(']') >> spaces? }

      rule(:err_v_local_term_code_ref) {
        str('[') >> alphanum >> match('[^\]]+') >> str(']') >> spaces? }

      rule(:v_iso8601_extended_date_time) {
        (match('[0-9]').repeat(4, 4) >> str('-') >>
         match('[0-1]') >> match('[0-9]') >> str('-') >>
         match('[0-3]') >> match('[0-9]') >> str('T') >>
         match('[0-2]') >> match('[0-9]') >> str(':') >>
         match('[0-6]') >> match('[0-9]') >> str(':') >>
         match('[0-6]') >> match('[0-9]') >>
         (str(',') >> match('[0-9]').repeat(1)).maybe >>
         (str('Z') | (match('[+-]') >> match('[0-9]').repeat(4,4))).maybe) |
        (match('[0-9]').repeat(4, 4) >> str('-') >>
         match('[0-1]') >> match('[0-9]') >> str('-') >>
         match('[0-3]') >> match('[0-9]') >> str('T') >>
         match('[0-2]') >> match('[0-9]') >> str(':') >>
         match('[0-6]') >> match('[0-9]') >>
         (str('Z') | (match('[+-]') >> match('[0-9]').repeat(4,4))).maybe) |
        (match('[0-9]').repeat(4, 4) >> str('-') >>
         match('[0-1]') >> match('[0-9]') >> str('-') >>
         match('[0-3]') >> match('[0-9]') >> str('T') >>
         match('[0-2]') >> match('[0-9]') >> str(':') >>
         (str('Z') | (match('[+-]') >> match('[0-9]').repeat(4,4))).maybe) }

      rule(:v_iso8601_extended_time) {
        (match('[0-2]') >> match('[0-9]') >> str(':') >>
         match('[0-6]') >> match('[0-9]') >> str(':') >>
         match('[0-6]') >> match('[0-9]') >>
         (str(',') >> match('[0-9]').repeat(1)).maybe >>
         (str('Z') | (match('[+-]') >> match('[0-9]').repeat(4,4))).maybe) |
        (match('[0-2]') >> match('[0-9]') >> str(':') >>
         match('[0-6]') >> match('[0-9]') >> str(':') >>
         (str('Z') | (match('[+-]') >> match('[0-9]').repeat(4,4))).maybe) }

      rule(:v_iso8601_extendate_date) {
        (match('[0-9]').repeat(4, 4) >> str('-') >>
         match('[0-1]') >> match('[0-9]') >> str('-') >>
         match('[0-3]') >> match('[0-9]')) |
        (match('[0-9]').repeat(4, 4) >> str('-') >>
         match('[0-1]') >> match('[0-9]')) }

      rule(:v_iso8601_duration) {
        (str('P') >>
        (match('[0-9]').repeat(1) >> stri('Y')).maybe >>
        (match('[0-9]').repeat(1) >> stri('M')).maybe >>
        (match('[0-9]').repeat(1) >> stri('W')).maybe >>
        (match('[0-9]').repeat(1) >> stri('D')).maybe >>
        str('T') >>
        (match('[0-9]').repeat(1) >> stri('H')).maybe >>
        (match('[0-9]').repeat(1) >> stri('M')).maybe >>
        (match('[0-9]').repeat(1) >>
         (str('.') >> match('[0-9]').repeat(1)).maybe >> stri('S')).maybe) |
        (str('P') >>
        (match('[0-9]').repeat(1) >> stri('Y')).maybe >>
        (match('[0-9]').repeat(1) >> stri('M')).maybe >>
        (match('[0-9]').repeat(1) >> stri('W')).maybe >>
        (match('[0-9]').repeat(1) >> stri('D')).maybe) }

      rule(:v_type_identifier) {
        match('[A-Z]') >> idchar.repeat }

      rule(:v_generic_type_identifier) {
        match('[A-Z]') >> idchar.repeat >>
        str('<') >> match('[a-zA-Z0-9,_<>]').repeat(1) >> str('>') }

      rule(:v_attribute_identifier) {
        match('[_a-z]') >> idchar.repeat }      

      rule(:v_archetype_id) {
        ((namestr >> (str('.') >> alphanum_str).repeat >> str('::')).maybe >> namestr >> str('-') >> alphanum_str >> str('-') >> namestr >> str('.') >> namestr >> (str('-') >> alphanum_str).repeat >> str('.v') >> match('[0-9]').repeat(1) >> ((str('.') >> match([0-9]).repeat(1)).repeat(0,2) >> (str('-rc') | str('+') | str('+') >> match([0-9]).repeat(1)).maybe).maybe) }

      rule(:v_identifier) {
        namestr }
      rule(:v_integer) {
        match('[0-9]').repeat(1) |
        (match('[0-9]').repeat(1) >> stri('e') >>
         match('[+-]').maybe >> match([0-9]).repeat(1)) }

      rule(:v_real) {
        match('[0-9]').repeat(1) >> str('.') >> match('[0-9]').repeat(1) |
        (match('[0-9]').repeat(1) >> str('.') >> match('[0-9]').repeat(1) >>
         stri('e') >> match('[+-]').maybe >> match([0-9]).repeat(1)) }

      rule(:v_string) {
        str('"') >> (str('\"')| match('[^"]')).repeat >> str('"') }

      rule(:v_char) {
        match('[^\\\n\"]') }
    end

    class ADL15Transformer < ::Parslet::Transform
      rule(archetype_id: sequence(:archetype_id), adl_version: simple(:adl_version)) { ArchMock.new(adl_version: adl_version, archetype_id: archetype_id)} 
    end
  end
end
