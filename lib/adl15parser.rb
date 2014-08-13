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

      rule(:arch_meta_data) {
        str('-/-') |
        str('(') >> arch_meta_data_items >> str(')') >> spaces? }

      rule(:arch_meta_data_items) {
        arch_meta_data_item >> (str(';') >> arch_meta_data_item).repeat }

      rule(:arch_meta_data_item) {
        sym_adl_version >> sym_eq >> version_string.as(:adl_version) |
        sym_uid >> sym_eq >> v_dottd}


      rule(:archetype_id) {
        ((namestr >> (str('.') >> alphanum_str).repeat >> str('::')).maybe >> namestr >> str('-') >> alphanum_str >> str('-') >> namestr >> str('.') >> namestr >> (str('-') >> alphanum_str).repeat >> str('.v') >> match('[0-9]').repeat(1) >> ((str('.') >> match([0-9]).repeat(1)).repeat(0,2) >> (str('-rc') | str('+') | str('+') >> match([0-9]).repeat(1)).maybe).maybe).as(:archetype_id) >> spaces? }

      rule (:arch_meta_data) {
        str('(') >>  arch_meta_data_items >> str(')') }

      rule(:arch_language) {
        sym_language >> spaces.maybe >> v_odin_text }

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

      rule(:v_attribute_identifier) {
        match('[a-z]') >> idchar.repeat }

      rule(:v_generic_type_identifier) {
        match('[A-Z]') >> idchar.repeat >> str('<') >> match('[a-zA-Z0-9,_]').repeat(1) >> str('>') }

      rule(:v_type_identifier) {
        match('[A-Z]') >> idchar.repeat }

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

      rule(:sym_adl_version) {
        stri('adl_version') >> spaces? }

      rule(:sym_is_controled) {
        stri('is_controlled') >> spaces? }
      
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

    end

    class ADL15Transformer < ::Parslet::Transform
      rule(archetype_id: sequence(:archetype_id), adl_version: simple(:adl_version)) { ArchMock.new(adl_version: adl_version, archetype_id: archetype_id)} 
    end
  end
end
