require 'openehr'
require 'parslet'

module OpenEHR
  module Parser
    class ADL15Parser < OpenEHR::Parser::Base
      def parse
        begin
          tree = parslet_engine.parse(filestream.read)
          arch_mock = transformer.apply(tree)
          filestream.close
        rescue Parslet::ParseFailed => e
#          puts e.error_tree
          puts e.cause.ascii_tree
        end        
        arch_mock
      end

      def filestream
        @filestream ||= File.open(@filename, 'r:bom|utf-8')
      end

      def parslet_engine
        @adl15parslet ||= ADL15Parslet.new
      end

      def transformer
        @adl15transformer ||= ADL15Transformer.new
      end
    end

    class ArchMock
      attr_accessor :adl_version, :archetype_id

      def initialize(attribute = {})
        @adl_version = attribute[:adl_version]
        @archetype_id = attribute[:archetype_id]
      end
    end

    class ADL15Transformer < ::Parslet::Transform
      rule(archetype_id: simple(:archetype_id),
           adl_version: simple(:adl_version)) {
        ArchMock.new(adl_version: adl_version, archetype_id: archetype_id) }
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
          arch_language >> any.repeat #>>
          # arch_description >>
          # arch_definition >>
          # arch_rules >>
          # arch_terminology >>
          # arch_annotations
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
        sym_uid >> sym_eq >> v_dotted_numeric |
        sym_uid >> sym_eq >> v_value |
        sym_is_controlled |
        sym_is_generated |
        v_identifier >> sym_eq >> v_identifier |
        v_identifier >> sym_eq >> v_value |
        v_identifier |
        v_value }

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
        sym_annotations >> v_odin_text }

      # ODIN
      rule(:v_odin_text) {
        attr_vals |
        complex_object_block }

      rule(:attr_vals) {
        attr_val >> (str(';').maybe >> spaces >> attr_val).repeat}

      rule(:attr_val) {
        attr_id >> sym_eq >> object_block >> spaces? }

      rule(:attr_id) {
        v_attribute_identifier >> spaces? }

      rule(:object_block) {
        complex_object_block |
        primitive_object_block |
        object_reference_block |
        (sym_start_dblock >> sym_end_dblock)}

      rule(:complex_object_block) {
        single_attr_object_block |
        container_attr_object_block }

      rule(:container_attr_object_block) {
        untyped_container_attr_object_block |
        (type_identifier >> untyped_container_attr_object_block) }

      rule(:untyped_container_attr_object_block) {
        container_attr_object_block_head >> keyed_objects >> sym_end_dblock }

      rule(:container_attr_object_block_head) {
        sym_start_dblock >> spaces? }

      rule(:keyed_objects) {
        keyed_object.repeat }

      rule(:keyed_object) {
        object_key >> sym_eq >> object_block }

      rule(:object_key) {
        str('[') >> primitive_value >> str(']')}

      rule(:single_attr_object_block) {
        untyped_single_attr_object_block |
        type_identifier.maybe >> untyped_single_attr_object_block }

      rule(:untyped_single_attr_object_block) {
        single_attr_object_complex_head >> attr_vals >> sym_end_dblock }

      rule(:single_attr_object_complex_head) {
        sym_start_dblock }

      rule(:primitive_object_block) {
        untyped_primitive_object_block |
        (type_identifier >> untyped_primitive_object_block) }

     rule(:untyped_primitive_object_block) {
        sym_start_dblock >> primitive_object >> sym_end_dblock }

      rule(:primitive_object) {
        term_code_list_value |
        term_code |
        primitive_interval_value |
        primitive_list_value |
        primitive_value }

      rule(:primitive_value) {
        uri_value |
        duration_value |
        date_time_value |
        time_value |
        date_value |
        boolean_value |
        real_value |
        integer_value |
        string_value |
        character_value }

      rule(:primitive_list_value) {
        duration_list_value |
        date_time_list_value |
        time_list_value |
        date_list_value |
        boolean_list_value |
        real_list_value |
        integer_list_value |
        string_list_value |
        character_list_value }

      rule(:primitive_interval_value) {
        duration_interval_value |
        date_time_interval_value |
        time_interval_value |
        date_interval_value |
        boolean_value |
        real_interval_value |
        integer_interval_value }
      
      rule(:type_identifier) {
        str('(') >> v_type_identifier >> str(')') |
        str('(') >> v_generic_type_identifier >> str(')') |
        v_type_identifier |
        v_generic_type_identifier }

      rule(:string_value) {
        v_string }

      rule(:string_list_value) {
        v_string >> (str(',') >> v_string).repeat(1) >>
        (str(',') >> sym_list_continue).maybe |
        v_string >> sym_list_continue }

      rule(:integer_value) {
        str('+') >> v_integer |
        str('-') >> v_integer |
        v_integer }

      rule(:integer_list_value) {
        integer_value >> (str(',') >> integer_value).repeat(1) |
        integer_value >> str(',') >> sym_list_continue }

      rule(:integer_interval_value) {
        sym_interval_delim >> integer_value >> sym_ellipsis >> integer_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> integer_value >> sym_ellipsis >> integer_value |
        sym_interval_delim >> integer_value >> sym_ellipsis >> sym_lt >> integer_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> integer_value >> sym_ellipsis >> sym_lt >> integer_value >> sym_interval_delim |
        sym_interval_delim >> sym_lt >> integer_value >> sym_interval_delim |
        sym_interval_delim >> sym_le >> integer_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> integer_value >> sym_interval_delim |
        sym_interval_delim >> sym_ge >> integer_value >> sym_interval_delim |
        sym_interval_delim >> integer_value >> sym_interval_delim }

      rule(:real_value) {
        str('+') >> v_real |
        str('-') >> v_real |
        v_real }

      rule(:real_list_value) {
        real_value >> (str(',') >> real_value).repeat(1) |
        real_value >> str(',') >> sym_list_continue }

      rule(:real_interval_value) {
        sym_interval_delim >> real_value >> sym_ellipsis >> real_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> real_value >> sym_ellipsis >> real_value >> sym_interval_delim |
        sym_interval_delim >> real_value >> sym_ellipsis >> sym_lt >> real_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> real_value >> sym_ellipsis >> sym_lt >> real_value >> sym_interval_delim |
        sym_interval_delim >> sym_lt >> real_value >> sym_interval_delim |
        sym_interval_delim >> sym_le >> real_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> real_value >> sym_interval_delim |
        sym_interval_delim >> sym_ge >> real_value >> sym_interval_delim |
        sym_interval_delim >> real_value >> sym_interval_delim }

      rule(:boolean_value) {
        sym_true |
        sym_false }

      rule(:boolean_list_value) {
        boolean_value >> (str(',') >> boolean_value).repeat(1) |
        boolean_value >> str(',') >> sym_list_continue }

      rule(:character_value) {
        v_character >> spaces? }

      rule(:character_list_value) {
        character_value >> (str(',') >> character_value).repeat(1)
        character_value >> str(',') >> sym_list_continue }

      rule(:date_value) {
        v_iso8601_extended_date >> spaces? }

      rule(:date_list_value) {
        date_value >> (str(',') >> date_value).repeat(1) |
        date_value >> str(',') >> sym_list_continue }

      rule(:date_interval_value) {
        sym_interval_delim >> date_value >> sym_ellipsis >> date_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> date_value >> sym_ellipsis >> date_value >> sym_interval_delim |
        sym_interval_delim >> date_value >> sym_ellipsis >> sym_lt >> date_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> date_value >> sym_ellipsis >> sym_lt >> date_value >> sym_interval_delim |
        sym_interval_delim >> sym_lt >> date_value >> sym_interval_delim |
        sym_interval_delim >> sym_le >> date_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> date_value >> sym_interval_delim |
        sym_interval_delim >> sym_ge >> date_value >> sym_interval_delim |
        sym_interval_delim >> date_value >> sym_interval_delim }

      rule(:time_value) {
        v_iso8601_extended_time >> spaces? }

      rule(:time_list_value) {
        time_value >> (str(',') >> time_value).repeat(1) |
        time_value >> str(',') >> sym_list_continue }

      rule(:time_interval_value) {
        sym_interval_delim >> time_value >> sym_ellipsis >> time_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> time_value >> sym_ellipsis >> time_value >> sym_interval_delim |
        sym_interval_delim >> time_value >> sym_ellipsis >> sym_lt >> time_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> time_value >> sym_ellipsis >> sym_lt >> time_value >> sym_interval_delim |
        sym_interval_delim >> sym_lt >> time_value >> sym_interval_delim |
        sym_interval_delim >> sym_le >> time_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> time_value >> sym_interval_delim |
        sym_interval_delim >> sym_ge >> time_value >> sym_interval_delim |
        sym_interval_delim >> time_value >> sym_interval_delim }

      rule(:date_time_value) {
        v_iso8601_extended_date_time >> spaces?}

      rule(:date_time_list_value) {
        date_time_value >> (str(',') >> date_time_value).repeat(1) |
        date_time_value >> str(',') >> sym_list_continue }

      rule(:date_time_interval_value) {
        sym_interval_delim >> date_time_value >> sym_ellipsis >> date_time_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> date_time_value >> sym_ellipsis >> date_time_value >> sym_interval_delim |
        sym_interval_delim >> date_time_value >> sym_ellipsis >> sym_lt >> date_time_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> date_time_value >> sym_ellipsis >> sym_lt >> date_time_value >> sym_interval_delim |
        sym_interval_delim >> sym_lt >> date_time_value >> sym_interval_delim |
        sym_interval_delim >> sym_le >> date_time_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> date_time_value >> sym_interval_delim |
        sym_interval_delim >> sym_ge >> date_time_value >> sym_interval_delim |
        sym_interval_delim >> date_time_value >> sym_interval_delim }

      rule(:duration_value) {
        v_iso8601_duration >> spaces? }

      rule(:duration_list_value){
        duration_value >> (str(',') >> duration_value).repeat(1) |
        duration_value >> str(',') >> sym_list_continue }

      rule(:duration_interval_value){
        sym_interval_delim >> duration_value >> sym_ellipsis >> duration_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> duration_value >> sym_ellipsis >> duration_value >> sym_interval_delim |
        sym_interval_delim >> duration_value >> sym_ellipsis >> sym_lt >> duration_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> duration_value >> sym_ellipsis >> sym_lt >> duration_value >> sym_interval_delim |
        sym_interval_delim >> sym_lt >> duration_value >> sym_interval_delim |
        sym_interval_delim >> sym_le >> duration_value >> sym_interval_delim |
        sym_interval_delim >> sym_gt >> duration_value >> sym_interval_delim |
        sym_interval_delim >> sym_ge >> duration_value >> sym_interval_delim |
        sym_interval_delim >> duration_value >> sym_interval_delim }

      rule(:term_code) {
        v_qualified_term_code_ref |
        err_v_qualified_term_code_ref }

      rule(:term_code_list_value) {
        term_code >> (str(',') >> term_code).repeat(1) |
        term_code >> sym_list_continue }

      rule(:uri_value) {
        v_uri >> spaces? }

      rule(:object_reference_block) {
        sym_start_dblock >> absolute_path_object_value >> sym_end_dblock }

      # Path
      rule(:absolute_path_object_value) {
        absolute_path |
        absolute_path_list }

      rule(:absolute_path_list) {
        absolute_path >> (str('.') >> absolute_path).repeat(1) |
        absolute_path >> str('.') >> sym_list_continue }

      rule(:absolute_path) {
        str('/') >> relative_path.repeat }

      rule(:relative_path) {
        path_segment >> (str('/') >> path_segment).repeat }

      rule(:path_segment) {
        v_attribute_identifier >> str('[') >> v_string >> str(']') |
        v_attribute_identifier }
 
      # Definitions
      rule(:alphanum) {
        match '[a-zA-Z0-9]' }

      rule(:alphanum_str) {
        match('[a-zA-Z0-9_]').repeat(1) }

      rule(:value_str) {
        match('[a-zA-Z0-9._\-]').repeat(1) }

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

      rule(:space) { match '\\s' }

      # rule(:space?) { space.maybe? }

      rule(:spaces) { space.repeat }

      rule(:comment) {
        str('--') >> any.repeat >> match("\\n") }

      rule(:spaces?) {
        spaces >> comment.maybe >> spaces }

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

      rule(:sym_uid) {
        stri('uid') >> spaces? }

      rule(:sym_start_dblock) {
        str('<') >> spaces? }

      rule(:sym_end_dblock) {
        str('>') >> spaces? }

      rule(:sym_interval_delim) {
        str('|') >> spaces? }

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
        str('[') >> namechar_paren.repeat(1) >>
        str('::') >> namechar_space.repeat(1)>> str(']') >> spaces? }

      rule(:v_local_term_code_ref) {
        str('[') >> str('a') >> (str('c') | str('t')) >> match('[0-9.]').repeat(1) >> str(']') >> spaces? }

      rule(:err_v_local_term_code_ref) {
        str('[') >> alphanum >> match('[^\]]').repeat(1) >> str(']') >> spaces? }

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

      rule(:v_iso8601_extended_date) {
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

      rule(:v_value) {
        value_str }

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

      rule(:v_character) {
        match('[^\\\n\"]') }
    end
  end
end
