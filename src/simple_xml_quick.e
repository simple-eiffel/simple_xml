note
	description: "[
		Zero-configuration XML facade for beginners.

		One-liner XML parse and query operations.
		For full control, use SIMPLE_XML directly.

		Quick Start Examples:
			create xml.make

			-- Parse XML string
			doc := xml.parse (xml_string)

			-- Query with XPath
			titles := xml.xpath (xml_string, "//book/title")

			-- Get first match
			title := xml.first (xml_string, "//book/title")

			-- Get attribute
			id := xml.attr (xml_string, "//book", "id")
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_XML_QUICK

create
	make

feature {NONE} -- Initialization

	make
			-- Create quick XML facade.
		do
			create xml.make
			last_error := ""
		ensure
			xml_exists: xml /= Void
		end

feature -- Parsing

	parse (a_xml: STRING): detachable SIMPLE_XML_DOCUMENT
			-- Parse XML string to document.
		require
			xml_not_empty: not a_xml.is_empty
		do
			last_error := ""
			Result := xml.parse (a_xml)
			if Result = Void then
				last_error := "Parse failed"
			end
		end

	parse_file (a_path: STRING): detachable SIMPLE_XML_DOCUMENT
			-- Parse XML file to document.
		require
			path_not_empty: not a_path.is_empty
		do
			last_error := ""
			Result := xml.parse_file (a_path)
			if Result = Void then
				last_error := "Parse file failed"
			end
		end

feature -- XPath Queries (one-liners)

	xpath (a_xml: STRING; a_query: STRING): ARRAYED_LIST [STRING]
			-- Execute XPath query, return text content of matching nodes.
		require
			xml_not_empty: not a_xml.is_empty
			query_not_empty: not a_query.is_empty
		do
			create Result.make (10)
			if attached xml.parse (a_xml) as doc then
				if attached xml.query (doc, a_query) as nodes then
					across nodes as n loop
						if attached n.text_content as t then
							Result.extend (t)
						end
					end
				end
			end
		ensure
			result_exists: Result /= Void
		end

	first (a_xml: STRING; a_query: STRING): detachable STRING
			-- Get text content of first matching node.
		require
			xml_not_empty: not a_xml.is_empty
			query_not_empty: not a_query.is_empty
		local
			l_results: ARRAYED_LIST [STRING]
		do
			l_results := xpath (a_xml, a_query)
			if not l_results.is_empty then
				Result := l_results.first
			end
		end

	attr (a_xml: STRING; a_query: STRING; a_attr_name: STRING): detachable STRING
			-- Get attribute value from first matching node.
		require
			xml_not_empty: not a_xml.is_empty
			query_not_empty: not a_query.is_empty
			attr_not_empty: not a_attr_name.is_empty
		do
			if attached xml.parse (a_xml) as doc then
				if attached xml.query (doc, a_query) as nodes and then not nodes.is_empty then
					Result := nodes.first.attribute_value (a_attr_name)
				end
			end
		end

	count (a_xml: STRING; a_query: STRING): INTEGER
			-- Count matching nodes.
		require
			xml_not_empty: not a_xml.is_empty
			query_not_empty: not a_query.is_empty
		do
			if attached xml.parse (a_xml) as doc then
				if attached xml.query (doc, a_query) as nodes then
					Result := nodes.count
				end
			end
		end

	exists (a_xml: STRING; a_query: STRING): BOOLEAN
			-- Does at least one node match the query?
		require
			xml_not_empty: not a_xml.is_empty
			query_not_empty: not a_query.is_empty
		do
			Result := count (a_xml, a_query) > 0
		end

feature -- Element Access

	text (a_xml: STRING; a_element: STRING): detachable STRING
			-- Get text content of element by tag name (first match).
			-- Simpler than XPath for basic queries.
		require
			xml_not_empty: not a_xml.is_empty
			element_not_empty: not a_element.is_empty
		do
			Result := first (a_xml, "//" + a_element)
		end

	texts (a_xml: STRING; a_element: STRING): ARRAYED_LIST [STRING]
			-- Get text content of all elements by tag name.
		require
			xml_not_empty: not a_xml.is_empty
			element_not_empty: not a_element.is_empty
		do
			Result := xpath (a_xml, "//" + a_element)
		ensure
			result_exists: Result /= Void
		end

feature -- Building

	element (a_name: STRING; a_content: STRING): STRING
			-- Create simple element: <name>content</name>
		require
			name_not_empty: not a_name.is_empty
		do
			Result := "<" + a_name + ">" + escape_xml (a_content) + "</" + a_name + ">"
		ensure
			result_not_empty: not Result.is_empty
		end

	element_with_attrs (a_name: STRING; a_attrs: ARRAY [TUPLE [name: STRING; value: STRING]]; a_content: STRING): STRING
			-- Create element with attributes.
		require
			name_not_empty: not a_name.is_empty
		do
			Result := "<" + a_name
			across a_attrs as a loop
				Result.append (" " + a.name + "=%"" + escape_xml (a.value) + "%"")
			end
			Result.append (">" + escape_xml (a_content) + "</" + a_name + ">")
		ensure
			result_not_empty: not Result.is_empty
		end

feature -- Validation

	is_valid (a_xml: STRING): BOOLEAN
			-- Is string valid XML?
		require
			xml_not_void: a_xml /= Void
		do
			Result := attached xml.parse (a_xml)
			if not Result then
				last_error := "Invalid XML"
			else
				last_error := ""
			end
		end

feature -- Status

	last_error: STRING
			-- Last error message.

	has_error: BOOLEAN
			-- Did last operation fail?
		do
			Result := not last_error.is_empty
		end

feature -- Advanced Access

	xml: SIMPLE_XML
			-- Access underlying XML handler for advanced operations.

feature {NONE} -- Implementation

	escape_xml (a_text: STRING): STRING
			-- Escape XML special characters.
		do
			Result := a_text.twin
			Result.replace_substring_all ("&", "&amp;")
			Result.replace_substring_all ("<", "&lt;")
			Result.replace_substring_all (">", "&gt;")
			Result.replace_substring_all ("%"", "&quot;")
			Result.replace_substring_all ("'", "&apos;")
		end

invariant
	xml_exists: xml /= Void
	last_error_exists: last_error /= Void

end
