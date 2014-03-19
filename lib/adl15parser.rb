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
      attr_accessor :adl_version

      def initialize(attribute = {})
        @adl_version = attribute[:adl_version]
      end
    end

    class ADL15Parslet < ::Parslet::Parser
      root :archetype
      rule(:archetype) do
        sym_archetype >> space.maybe >>
          (str('(') >> sym_adl_version >> sym_eq >> version_string.as(:adl_version) >> str(')')).maybe >>
          any.repeat
      end

      rule(:sym_archetype) { str 'archetype'}
      rule(:sym_adl_version) { str 'adl_version' }
      rule(:version_string) { number >> str('.') >> number >> (str('.') >> number).maybe}
      rule(:space) { match '\s' }
      rule(:number) {match '[0-9]'}
      rule(:sym_eq) { str '=' }
    end

    class ADL15Transformer < ::Parslet::Transform
      rule(adl_version: simple(:s)) { ArchMock.new(adl_version: s.to_s) }
    end
  end
end
