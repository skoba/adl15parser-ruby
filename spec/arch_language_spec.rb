# -*- coding: utf-8 -*-
describe 'arch_language parser' do
  let(:parser) { OpenEHR::Parser::ADL15Parslet.new.arch_language }

  it 'parse language section' do
    expect(parser).to parse ORIGINAL_LANGUAGE
  end

  it 'parse and transform langauage section' do
    transformer = ADL15LangTransformer.new
    p transformer.apply(parser.parse(ORIGINAL_LANGUAGE))
  end

  it 'parse with multiple translations' do
    expect(parser).to parse WITH_TRANSLATIONS
  end
end

class ADL15LangTransformer < ::Parslet::Transform
  rule original_language(language: simple(:language)) do
    language_to_s
  end
end

ORIGINAL_LANGUAGE =<<DOC
language
	original_language = <[ISO_639-1::en]>
DOC

WITH_TRANSLATIONS =<<DOC
language
	original_language = <[ISO_639-1::en]>
	translations = <
		["de"] = <
			language = <[ISO_639-1::de]>
			author = <
				["name"] = <"Sebastian Garde, Jasmin Buck">
				["organisation"] = <"Ocean Informatics, University of Heidelberg">
			>
		>
		["zh-cn"] = <
			language = <[ISO_639-1::zh-cn]>
			author = <
				["name"] = <"Chunlan Ma, Lin Zhang">
				["organisation"] = <"Ocean Informatics, BIPH">
				["email"] = <", linforest@163.com">
			>
			accreditation = <"What goes here?">
		>
		["ko"] = <
			language = <[ISO_639-1::ko]>
			author = <
				["name"] = <"Seung-Jong Yu">
				["organisation"] = <"NOUSCO Co.,Ltd.">
				["email"] = <"seungjong.yu@gmail.com">
			>
		>
		["ar-sy"] = <
			language = <[ISO_639-1::ar-sy]>
			author = <
				["name"] = <"Mona Saleh">
			>
		>
		["es-ar"] = <
			language = <[ISO_639-1::es-ar]>
			author = <
				["name"] = <"Domingo Liotta">
				["organisation"] = <"Universidad de Morón">
				["email"] = <"domingo_liotta@hotmail.com">
			>
			accreditation = <"Universidad de Morón">
		>
		["fa"] = <
			language = <[ISO_639-1::fa]>
			author = <
				["name"] = <"Shahla Foozonkhah">
				["organisation"] = <"Ocean Informatics">
				["email"] = <"shahla.foozonkhah@oceaninformatics.com">
			>
		>
		["ru"] = <
			language = <[ISO_639-1::ru]>
			author = <
				["name"] = <"Igor Lizunov">
				["email"] = <"i.lizunov@infinnity.ru">
			>
		>
		["ja"] = <
			language = <[ISO_639-1::ja]>
			author = <
				["name"] = <"Shinji Kobayashi">
				["organisation"] = <"Kyoto University">
				["email"] = <"skoba@moss.gr.jp">
			>
		>
		["nl"] = <
			language = <[ISO_639-1::nl]>
			author = <
				["name"] = <"Marja Buur">
				["organisation"] = <"M.C.A.">
				["email"] = <"m.buur-krom@mca.nl">
			>
		>
		["pt-br"] = <
			language = <[ISO_639-1::pt-br]>
			author = <
				["name"] = <"Jussara Rözsch">
				["organisation"] = <"OpenEHR  Foundation">
				["email"] = <"jussara.macedo@gmail.com">
			>
			accreditation = <"Medical Doctor, Psychiarist, Clinical Modeller, openEHR Diretor, ehealth infostructuture WG ccoordinator- brazilian  ehealth program">
		>
	>
DOC
