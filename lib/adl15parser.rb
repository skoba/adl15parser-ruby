require 'openehr'
require 'parslet'
require 'parslet/convenience'

module OpenEHR
  module Parser
    class ADL15Parser < OpenEHR::Parser::Base
      def parse
        if File.exist? @filename
          context = filestream.read
        else
          context = @filename
        end

        begin
          tree = parslet_engine.parse_with_debug(context)
#p tree
          arch_mock = transformer.apply(tree)
#p arch_mock
          filestream.close
        rescue Parslet::ParseFailed => e
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
      attr_accessor :adl_version, :archetype_id, :language

      def initialize(attribute = {})
        @adl_version = attribute[:adl_version]
        @archetype_id = attribute[:archetype_id]
        @language = attribute[:language]
      end
    end

    class ADL15Transformer < ::Parslet::Transform
      rule(terminology_id: simple(:id)) do
        OpenEHR::RM::Support::Identification::TerminologyID.new(value: id.to_s)
      end

      rule(term_code: {terminology_id: simple(:id), code: simple(:c)}) do
        OpenEHR::RM::DataTypes::Text::CodePhrase.new(terminology_id: id, code_string: c.to_s)
      end

      rule(archetype_id: simple(:archetypeid),
           adl_version: simple(:adlversion),
           language: subtree(:language)) {
        ArchMock.new(adl_version: adlversion.to_s, archetype_id: archetypeid.to_s, language: language) }
    end

    class ADL15Parslet < ::Parslet::Parser
      def stri(str)
        key_chars = str.split(//)
        key_chars.
          collect! { |char| match["#{char.upcase}#{char.downcase}"] }.
          reduce(:>>)
      end

      root :input

      rule(:input) {
        archetype }#|
#        specialised_archetype |
#        tempalate |
#        template_overlay |
#        operational_template }

      rule(:archetype) do
        archetype_marker >>
          arch_meta_data.maybe >>
          archetype_id >> 
          arch_language >> 
          arch_description >>
          arch_definition >>
          arch_rules.maybe >>
          arch_terminology >>
          arch_annotations.maybe
      end

      rule(:archetype_marker) {
        sym_archetype }

      rule(:archetype_id) {
        v_archetype_id.as(:archetype_id) >> spaces }

      rule(:arch_meta_data) {
        str('(') >> arch_meta_data_items >> str(')') >> spaces }

      rule(:arch_meta_data_items) {
        arch_meta_data_item >> (str(';') >> spaces.maybe >> arch_meta_data_item).repeat }

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
        sym_language >> v_odin_text.as(:language) }

      rule(:arch_description) {
        sym_description >> v_odin_text.as(:description) }

      rule(:arch_definition) {
        sym_definition >> v_cadl_text }

      rule(:arch_rules) {
        str('-/-') |
        sym_rules >> v_rules_text }

      rule(:arch_terminology) {
        (sym_terminology | sym_ontology) >> v_odin_text }

      rule(:arch_annotations) {
#        str('-/-') |
        sym_annotations >> v_odin_text }

      # cADL
      rule(:v_cadl_text) {
        c_complex_object }

      rule(:c_complex_object) do
        (c_complex_object_head >>
         sym_matches >>
         sym_start_cblock >>
         c_complex_object_body >>
         sym_end_cblock) |
          c_complex_object_head 
      end

      rule(:c_complex_object_head) {
        c_complex_object_id >> spaces >> c_occurrences.maybe }

      rule(:c_complex_object_id) do
        type_identifier >> v_root_id_code |
        type_identifier >> v_id_code |
        sibling_order >> type_identifier >> v_id_code |
        type_identifier >> v_local_term_code_ref |    # ADL 1.4 atXXXX code
          type_identifier
      end

      rule(:sibling_order) {
        sym_after >> v_id_code |
        sym_before >> v_id_code }

      rule(:c_complex_object_body) {
        c_any |
        c_attribute_defs }

      rule(:c_object) do
        c_complex_object |
          c_complex_object_proxy|
          archetype_slot |
          c_primitive_object
      end

      rule(:c_archetype_root) {
        sym_use_archtype >> type_identifier >> v_id_code >> c_occurrences >> v_archetype_id }

      rule(:c_complex_object_proxy) {
        sym_use_node >> type_identifier >> v_id_code >> c_occurrences >> absolute_path }

      rule(:archetype_slot) {
        c_archetype_slot_head >> sym_matches >> sym_start_cblock >> c_includes.maybe >> c_excludes.maybe >> sym_end_cblock |
        c_archetype_slot_head }

      rule(:c_archetype_slot_head) {
        c_archetype_slot_id >> c_occurrences }

      rule(:c_archetype_slot_id) {
        sym_allow_archetype >> type_identifier >> v_id_code |
        sibling_order >> sym_allow_archetype >> type_identifier >> v_id_code |
        sym_allow_archetype >> type_identifier >> v_id_code >> sym_closed }

      rule(:c_primitive_object) {
        c_primitive }

      rule(:c_primitive) {
#        c_terminology_code |
        c_boolean |
        c_duration |
        c_date_time |
        c_time |
        c_date |
        c_real |
        c_integer |
        c_string }

      rule(:c_any) { str '*' }

      rule(:c_attribute_defs) {
        c_attribute_def.repeat(1) }

      rule(:c_attribute_def) {
        c_attribute_tuple |
        c_attribute }

      rule(:c_attribute) {
        c_attr_head >> spaces >> sym_matches >> sym_start_cblock >> c_attr_values >> sym_end_cblock }

      rule(:c_attr_head) {
        v_attribute_identifier >> c_existence.maybe >> c_cardinality.maybe |
        v_abs_path >> c_existence.maybe >> c_cardinality.maybe }

      rule(:c_attr_values) {
        c_object.repeat(1) | c_any }

      rule(:c_attribute_tuple) {
        str('[') >> c_tuple_attr_ids >> str(']') >> spaces >> sym_matches >> sym_start_cblock >> c_attr_tuple_values >> sym_end_cblock }
      rule(:c_tuple_attr_ids) {
        v_attribute_identifier >> (str(',') >> spaces >> v_attribute_identifier).repeat }

      rule(:c_attr_tuple_values) {
        c_attr_tuple_value >> (str(',') >> spaces >> c_attr_tuple_value).repeat }

      rule(:c_attr_tuple_value) {
        str('[') >> c_tuple_value >> str(']') }

      rule(:c_tuple_values) {
        sym_start_cblock >> c_primitive_object >> sym_end_cblock >> (str('.') >> spaces >> sym_start_cblock >> c_primitive_object >> sym_end_cblock).repeat }

      rule(:c_includes) {
#        str('-/-') |
        sym_include >> assertions }

      rule(:c_excludes) {
#        str('-/-') |
        sym_exclude >> assertions }

      rule(:c_existence) {
#        str('-/-') |
        sym_existence >> sym_matches >> sym_start_cblock >> existence_spec >> sym_end_cblock }

      rule(:existence_spec) {
        v_integer >> sym_ellipsis >> v_integer |
        v_integer }

      rule(:c_cardinality) {
#        str('-/-') |
        sym_cardinality >> sym_matches >> sym_start_cblock >> cardinality_range >> sym_end_cblock }

      rule(:cardinality_range) {
        occurence_spec |
        occurrence_spec >> str(';') >> spaces >> sym_ordered |
        occurrence_spec >> str(';') >> spaces >> sym_unordered |
        occurrence_spec >> str(';') >> spaces >> sym_unique |
        occurrence_spec >> str(';') >> spaces >> sym_ordered >> str(';') >> spaces >> sym_unique |
        occurrence_spec >> str(';') >> spaces >> sym_unordered >> str(';') >> spaces >> sym_unique |
        occurrence_spec >> str(';') >> spaces >> sym_unique >> str(';') >> spaces >> sym_ordered |
        occurrence_spec >> str(';') >> spaces >> sym_unique >> str(';') >> spaces >> sym_unordered }

      rule(:c_occurrences) {
 #       str('-/-') |
        sym_occurrences >> sym_matches >> sym_start_cblock >> occurrence_spec >> sym_end_cblock }

      rule(:occurrence_spec) {
        v_integer >> sym_ellipsis >> integer_value |
        v_integer >> sym_ellipsis >> str('*') |
        str('*') |
        integer_value }

      rule(:c_integer) {
        integer_interval_value
        integer_list_value |
        integer_value >> (str(';') >> spaces >> integer_value).repeat }

      rule(:c_real) {
        real_interval_value
        real_list_value |
        real_value >> (str(';') >> spaces >> real_value).repeat }

      rule(:c_date) {
        v_iso8601_date_constraint_pattern |
        date_interval_value |
        date_value >> (str(';') >> spaces >> date_value).repeat }

      rule(:c_time) {
        v_iso8601_time_constraint_pattern |
        time_interval_value |
        time_value >> (str(';') >> spaces >> time_value).repeat }

      rule(:c_date_time) {
        v_iso8601_date_time_constraint_pattern |
        date_time_interval_value |
        date_time_value >> (str(';') >> spaces >> date_time_value).repeat }

      rule(:c_duration) {
        v_iso8601_duration_constraint_pattern >> str('/') >> duration_interval_value |
        v_iso8601_duration_constraint_pattern |
        duration_interval_value |
        duration_value >> (str(';') >> spaces >> duration_value).repeat }

      rule(:c_string) {
#        string_list_value_continue |
        string_list_value |
        v_regexp |
        string_value >> (str(';') >> spaces >> string_value).repeat(1) |
        v_string }

      rule(:c_boolean) {
        boolean_value >> (str(';') >> spaces >> boolean_value).repeat(1) |
        sym_true >> spaces >> str(',') >> spaces >> sym_false |
        sym_false >> spaces >> str(',') >> spaces >> sym_true |
        sym_true |
        sym_false }

      rule(:any_identifier) {
        type_identifier |
        v_attribute_identifier }

      # ODIN
      rule(:v_odin_text) {
        attr_vals.as(:attr_vals) |
        complex_object_block.as(:complex_object) }

      rule(:attr_vals) {
        attr_val >> (str(';').maybe >> spaces >>
                     attr_val).repeat }

      rule(:attr_val) {
        attr_id.as(:id) >> sym_eq >>
        object_block.as(:value) }

      rule(:attr_id) {
        v_attribute_identifier.as(:value) >> spaces }

      rule(:object_block) {
        complex_object_block |
        primitive_object_block |
        object_reference_block |
        sym_start_dblock >> sym_end_dblock }

      rule(:complex_object_block) {
        single_attr_object_block.as(:single_attr) |
        container_attr_object_block.as(:container_attr) }

      rule(:container_attr_object_block) {
        type_identifier.maybe >>
        untyped_container_attr_object_block.as(:container) }

      rule(:untyped_container_attr_object_block) {
        container_attr_object_block_head >>
        keyed_objects >> sym_end_dblock }

      rule(:container_attr_object_block_head) {
        sym_start_dblock }

      rule(:keyed_objects) {
        (keyed_object.as(:keyed_object)).repeat(1) }

      rule(:keyed_object) {
        object_key.as(:key) >> sym_eq >>
        object_block.as(:value) }

      rule(:object_key) {
        str('[') >> primitive_value.as(:value) >> str(']') >> spaces }

      rule(:single_attr_object_block) {
        type_identifier.maybe >>
        untyped_single_attr_object_block.as(:attr_object) }

      rule(:untyped_single_attr_object_block) {
        single_attr_object_complex_head >>
        attr_vals.as(:attr_vals) >> sym_end_dblock }

      rule(:single_attr_object_complex_head) {
        sym_start_dblock }

      rule(:primitive_object_block) {
        type_identifier.maybe >> untyped_primitive_object_block }

      rule(:untyped_primitive_object_block) do
        sym_start_dblock >>
          primitive_object >> spaces >>
          sym_end_dblock
      end

      rule(:primitive_object) {
        term_code_list_value |
        term_code |
        primitive_list_value |
        primitive_interval_value |
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
        (str('(') >> v_type_identifier >> str(')') |
         str('(') >> v_generic_type_identifier >> str(')') |
         v_type_identifier |
         v_generic_type_identifier) >>
        spaces }

      rule(:string_value) {
        v_string }

      rule(:string_list_value) {
        v_string >> (str(',') >> spaces >> v_string).repeat(1) >>
        (str(',') >> spaces >> sym_list_continue).maybe |
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
        v_character >> spaces }

      rule(:character_list_value) {
        character_value >> (str(',') >> character_value).repeat(1)
        character_value >> str(',') >> sym_list_continue }

      rule(:date_value) {
        v_iso8601_extended_date >> spaces }

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
        v_iso8601_extended_time >> spaces }

      rule(:time_list_value) {
        time_value >>(str(',') >> time_value).repeat(1) |
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
        v_iso8601_extended_date_time >> spaces }

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
        v_iso8601_duration >> spaces }

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
        v_qualified_term_code_ref.as(:term_code) |
        err_v_qualified_term_code_ref }

      rule(:term_code_list_value) {
        term_code >> (str(',') >> term_code).repeat(1) |
        term_code >> sym_list_continue }

      rule(:uri_value) {
        v_uri >> spaces }

      rule(:object_reference_block) {
        sym_start_dblock >> absolute_path_object_value >> sym_end_dblock }

      # Assertions
      rule(:v_rules_text) {
        assetions }

      rule(:assertions) {
        assertion.repeat(1) }

      rule(:assertion) {
        any_identifier >> str(':') >> spaces >> boolean_node |
        boolean_node |
        str('(') >> boolean_node >> str(')') |
        arch_outer_constraint_expr }

      rule(:boolean_node) {
        boolean_leaf |
        boolean_unop_expr |
        boolean_binop_expr |
        arithmetic_relop_expr |
        boolean_constraint_expr }

      rule(:arch_outer_constraint_expr) {
        v_rel_path >> sym_matches >> sym_start_cblock >> c_primitive >> sym_end_cblock }

      rule(:boolean_constraint_expr) {
        v_abs_path >> sym_matches >> sym_start_cblock >> c_primitive >> sym_end_cblock |
        v_abs_path >> sym_matches >> sym_start_cblock > c_code_phrase >> sym_end_cblock }

      rule(:boolean_unop_expr) {}

      # Path
      rule(:absolute_path_object_value) {
        absolute_path_list |
        absolute_path }

      rule(:absolute_path_list) {
        absolute_path >> (str('.') >> absolute_path).repeat(1) |
        absolute_path >> str('.') >> sym_list_continue }

      rule(:absolute_path) {
        str('/') >> relative_path.repeat }

      rule(:relative_path) {
        path_segment >> (str('/') >> path_segment).repeat }

      rule(:path_segment) {
        v_attribute_identifier >>
        (str('[') >> v_string >> str(']')).maybe }
 
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

      rule(:id_code_leader) {str 'id'}

      rule(:code_str) {
        (str('0') | (match('[1-9]') >> match('[0-9]').repeat)) >>
        (str('.') >> str('0') | (match('[1-9]') >> match('[0-9]').repeat)).repeat }

      rule(:path_seg) {
        match('[a-z]') >> match('[a-zA-Z0-9_]').repeat >> (str('[id') >> (str('0') | (match('[1-9]') >> match('[0-9]').repeat) >> (str('.') >> (str('0') | (match('[1-9]') >> match('[0-9]').repeat)).repeat >> str(']')))).maybe }

      rule(:number) {match '[0-9]'}

      rule(:v_dotted_numeric) {
        number >> str('.') >> number >> (str('.') >> number >> (str('-') >> alphanum_str).maybe).maybe }

      rule(:space) { match '\s' }

      rule(:spaces) { (space | comment).repeat }

      rule(:newline) { str("\r").maybe >> str("\n")  }

      rule(:comment) {
        str('--') >> (newline.absent? >> any).repeat }

      # Symbols
      rule(:sym_archetype) {
        stri('archetype') >> spaces }

      rule(:sym_template) {
        stri('template') >> spaces }

      rule(:sym_template_overlay) {
        stri('template_overlay') >> spaces }

      rule(:sym_operational_template) {
        stri('operational_template') >> spaces }

      rule(:sym_adl_version) {
        stri('adl_version') >> spaces }

      rule(:sym_is_controlled) {
        stri('controlled') >> spaces }

      rule(:sym_is_generated) {
        stri('generated') >> spaces }

      rule(:sym_specialize) {
        (stri('specialised') | stri('specialized')) >> spaces }

      rule(:sym_concept) {
        stri('concept') >> spaces }

      rule(:sym_definition) {
        stri('definition') >> spaces }

      rule(:sym_language) {
        stri('language') >> spaces }

      rule(:sym_description){
        stri('description') >> spaces }

      rule(:sym_invariant) {
        stri('invariant') >> spaces }

      rule(:sym_terminology) {
        stri('terminology') >> spaces }

      rule(:sym_ontology) {
        stri('ontology') >> spaces}

      rule(:sym_rules) {
        stri('rules') >> spaces }

      rule(:sym_annotations) {
        stri('annotations') >> spaces }

      rule(:sym_component_terminologies) {
        stri('component_terminologies') >> spaces }

      rule(:sym_uid) {
        stri('uid') >> spaces }

      rule(:sym_start_dblock) {
        str('<') >> spaces }

      rule(:sym_end_dblock) {
        str('>') >> spaces }

      rule(:sym_interval_delim) {
        str('|') >> spaces }

      rule(:sym_eq) {
        str('=') >> spaces }

      rule(:sym_ge) {
        str('>=') >> spaces }

      rule(:sym_le) {
        str('<=') >> spaces }

      rule(:sym_lt) { sym_start_dblock }

      rule(:sym_gt) { sym_end_dblock }

      rule(:sym_ellipsis) {
        str('..') >> spaces }

      rule(:sym_list_continue) {
        str('...') >> spaces }

      rule(:sym_true) {
        stri('true') >> spaces }

      rule(:sym_false) {
        stri('false') >> spaces }

# cADL symbols
      rule(:sym_start_cblock) {
        str('{') >> spaces }

      rule(:sym_end_cblock) {
        str('}') >> spaces}

      rule(:sym_matches) {
        (stri('matches') | stri('is_in')) >> spaces }

      rule(:sym_existence) {
        stri('existence') >> spaces }

      rule(:sym_occurrences) {
        stri('occurrences') >> spaces }

      rule(:sym_cardinality) {
        stri('cardinality') >> spaces }

      rule(:sym_use_node) {
        stri('use_node') >> spaces}

      rule(:sym_allow_archetype) {
        (stri('allow_archetype') | stri('use_archetype')) >> spaces }

      rule(:sym_after) {
        stri('after') >> spaces }

      rule(:sym_before) {
        stri('before') >> spaces } 

      rule(:sym_closed) {
        stri('closed') >> spaces }

      # valued strings
      rule(:v_uri) {
        (match('[a-z]').repeat(1) >> str('://') >>
        match('[^<>|\\{}^~"\[\])]').repeat).as(:uri) >> spaces }

      rule(:v_root_id_code) {
        str('[') >> id_code_leader >> str('1') >> str('.1').repeat >> str(']')}

      rule(:v_id_code) {
        str('[') >> id_code_leader >> code_str >> str(']') }

      rule(:v_qualified_term_code_ref) {
        str('[') >> namechar_paren.repeat(1).as(:terminology_id) >>
        str('::') >> namechar.repeat(1).as(:code) >> str(']') >> spaces }

      rule(:err_v_qualified_term_code_ref) {
        str('[') >> namechar_paren.repeat(1) >>
        str('::') >> namechar_space.repeat(1)>> str(']') >> spaces }

      rule(:v_local_term_code_ref) {
        str('[') >> (str('a') >> (str('c') | str('t')) >> match('[0-9.]').repeat(1)).as(:local_term_code) >> str(']') >> spaces }

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

      rule(:v_iso8601_date_constraint_pattern) {
        stri('YYYY') >> str('-') >> match('[mM?X]').repeat(2,2) >> str('-') >> match('[dD?X]').repeat(2,2) }

      rule(:v_iso8601_time_constraint_pattern) {
        stri('HH') >> str(':') >> match('[mM?X]').repeat(2,2) >> str(':') >> match('[sS?X]').repeat(2,2) }

      rule(:v_iso8601_date_time_constraint_pattern) {
        stri('YYYY') >> str('-') >>
        match('[mM?X]').repeat(2,2) >> str('-') >>
        match('[dD?X]').repeat(2,2)>> match('[T ]') >>
        stri('HH') >> str(':') >>
        match('[mM?X]').repeat(2,2) >> str(':') >>
        match('[sS?X]').repeat(2,2) }

      rule(:v_iso8601_duration_constraint_pattern) {
        str('P') >> stri('Y').maybe >> stri('M').maybe >> stri('W').maybe >> stri('D').maybe >> str('T') >> stri('H').maybe >> stri('M').maybe >> stri('S').maybe |
        str('P') >> stri('Y').maybe >> stri('M').maybe >> stri('W').maybe >> stri('D').maybe }

      rule(:v_type_identifier) {
        match('[A-Z]') >> idchar.repeat }

      rule(:v_generic_type_identifier) {
        match('[A-Z]') >> idchar.repeat >>
        str('<') >> match('[a-zA-Z0-9,_<>]').repeat(1) >> str('>') }

      rule(:v_attribute_identifier) {
        match('[_a-z]') >> idchar.repeat }      

      rule(:v_abs_path) {
      str('/')}
      rule(:v_archetype_id) {
        ((namestr >> (str('.') >> alphanum_str).repeat >>
          str('::')).maybe >>
         namestr >> str('-') >>
         alphanum_str >> str('-') >>
         namestr >> str('.') >>
         namestr >>
         (str('-') >> alphanum_str).repeat >>
         str('.v') >> match('[0-9]').repeat(1) >>
         ((str('.') >> match('[0-9]').repeat(1)).repeat(0,2) >>
          ((str('-rc') | str('+u') | str('+')) >> match('[0-9]').repeat(1)).maybe).maybe) }

      rule(:v_identifier) {
        namestr }

      rule(:v_value) {
        value_str.as(:value) }

      rule(:v_integer) {
        (match('[0-9]').repeat(1) |
        (match('[0-9]').repeat(1) >> stri('e') >>
         match('[+-]').maybe >> match([0-9]).repeat(1))).as(:value) }

      rule(:v_real) {
        match('[0-9]').repeat(1) >> str('.') >> match('[0-9]').repeat(1) |
        (match('[0-9]').repeat(1) >> str('.') >> match('[0-9]').repeat(1) >>
         stri('e') >> match('[+-]').maybe >> match([0-9]).repeat(1)) }

      rule(:v_string) do
        str('"') >>
        (
         (str("\\") >> any) |
         (str('"').absent? >> any)
         ).repeat.as(:value) >>
          str('"')
      end
      
      rule(:v_regexp) do
        str('/') >>
        (
         (str('\\') >> any) |
         (str('/').absent? >> any)
         ).repeat.as(:regexp) >>
          str('/')
      end

      rule(:v_character) {
        match('[^\\\n\"]') }
    end
  end
end
