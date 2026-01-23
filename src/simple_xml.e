note
	description: "[
		Simple XML - High-level XML parsing and building API

		Provides both direct and fluent APIs for XML manipulation:

		Direct API:
			create xml.make
			doc := xml.parse ("<root><item>value</item></root>")
			value := doc.text_at ("root/item")

		Fluent API:
			create xml.make
			value := xml.parse (source).root.element ("item").text

		Building:
			doc := xml.build ("root")
			         .element ("item").attr ("id", "1").text ("value").done
			       .to_document
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_XML

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize XML processor.
		do
			-- Ready to parse or build
		end

feature -- Parsing

	parse (a_xml: READABLE_STRING_GENERAL): SIMPLE_XML_DOCUMENT
			-- Parse XML from string `a_xml'.
		require
			xml_not_empty: not a_xml.is_empty
		do
			create Result.make_from_string (a_xml.to_string_8)
		ensure
			result_attached: Result /= Void
		end

	parse_file (a_path: READABLE_STRING_GENERAL): SIMPLE_XML_DOCUMENT
			-- Parse XML from file at `a_path'.
		require
			path_not_empty: not a_path.is_empty
		local
			l_file: PLAIN_TEXT_FILE
			l_content: STRING
		do
			create l_file.make_with_name (a_path.to_string_8)
			if l_file.exists and then l_file.is_readable then
				l_file.open_read
				l_file.read_stream (l_file.count)
				l_content := strip_utf8_bom (l_file.last_string)
				l_file.close
				create Result.make_from_string (l_content)
			else
				create Result.make_with_error ("File not found or not readable: " + a_path.to_string_8)
			end
		ensure
			result_attached: Result /= Void
		end

feature -- Query

	query (a_document: SIMPLE_XML_DOCUMENT; a_path: READABLE_STRING_GENERAL): ARRAYED_LIST [SIMPLE_XML_ELEMENT]
			-- Query elements at `a_path' from `a_document'.
			-- Path format: "root/child/element" (simple path, not full XPath)
		require
			document_valid: a_document.is_valid
			path_not_empty: not a_path.is_empty
		do
			Result := a_document.elements_at (a_path)
		ensure
			result_attached: Result /= Void
		end

feature -- Building

	build (a_root_name: READABLE_STRING_GENERAL): SIMPLE_XML_BUILDER
			-- Start building XML document with root element named `a_root_name'.
		require
			name_not_empty: not a_root_name.is_empty
		do
			create Result.make (a_root_name.to_string_8)
		ensure
			result_attached: Result /= Void
		end

	new_document (a_root_name: READABLE_STRING_GENERAL): SIMPLE_XML_DOCUMENT
			-- Create new empty document with root element named `a_root_name'.
		require
			name_not_empty: not a_root_name.is_empty
		do
			create Result.make_empty (a_root_name.to_string_8)
		ensure
			result_attached: Result /= Void
			result_valid: Result.is_valid
		end


feature {NONE} -- Implementation

	strip_utf8_bom (a_bytes: STRING_8): STRING_8
			-- Remove UTF-8 BOM (EF BB BF) if present at start of string.
		local
			l_detector: SIMPLE_ENCODING_DETECTOR
		do
			create l_detector.make
			if l_detector.has_utf8_bom (a_bytes) then
				Result := a_bytes.substring (4, a_bytes.count)
			else
				Result := a_bytes
			end
		ensure
			result_attached: Result /= Void
		end

feature {NONE} -- Type references (for `like` anchors only)

	xml_document_typeref: detachable SIMPLE_XML_DOCUMENT
		require
			type_ref_only_never_call: False
		attribute
		end

	xml_element_typeref: detachable SIMPLE_XML_ELEMENT
		require
			type_ref_only_never_call: False
		attribute
		end

	xml_builder_typeref: detachable SIMPLE_XML_BUILDER
		require
			type_ref_only_never_call: False
		attribute
		end

end