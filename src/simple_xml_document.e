note
	description: "[
		Parsed XML document with navigation and manipulation features.

		Navigation (direct):
			value := doc.text_at ("config/database/host")
			port := doc.attr_at ("config/database", "port")
			items := doc.elements_at ("root/items/item")

		Navigation (fluent):
			value := doc.root.element ("database").element ("host").text

		Modification:
			doc.root.element ("database").set_attr ("port", "5432")
			doc.root.add_element ("new_item").set_text ("content")

		Serialization:
			output := doc.to_string
			output := doc.to_pretty_string
			doc.save_to_file ("output.xml")
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_XML_DOCUMENT

inherit
	ANY
		redefine
			default_create
		end

create
	default_create,
	make_from_string,
	make_from_xm_document,
	make_empty,
	make_with_error

feature {NONE} -- Initialization

	default_create
			-- Create empty invalid document.
		do
			create error_message.make_empty
			is_valid := False
		end

	make_from_string (a_xml: STRING)
			-- Parse XML from `a_xml' string.
		require
			xml_not_void: a_xml /= Void
		local
			l_parser: XM_EIFFEL_PARSER
			l_pipe: XM_TREE_CALLBACKS_PIPE
		do
			create l_parser.make
			create l_pipe.make
			l_parser.set_callbacks (l_pipe.start)
			l_parser.parse_from_string (a_xml)

			if l_pipe.error.has_error then
				is_valid := False
				if attached l_pipe.error.last_error as l_err then
					error_message := l_err
				else
					error_message := "Unknown parse error"
				end
			else
				is_valid := True
				xm_document := l_pipe.document
				create root_element.make_from_xm_element (l_pipe.document.root_element)
				create error_message.make_empty
			end
		ensure
			valid_or_has_error: is_valid or not error_message.is_empty
		end

	make_from_xm_document (a_doc: XM_DOCUMENT)
			-- Wrap existing XM_DOCUMENT.
		require
			doc_not_void: a_doc /= Void
		do
			xm_document := a_doc
			create root_element.make_from_xm_element (a_doc.root_element)
			is_valid := True
			create error_message.make_empty
		ensure
			is_valid: is_valid
		end

	make_empty (a_root_name: STRING)
			-- Create new empty document with root named `a_root_name'.
		require
			name_not_void: a_root_name /= Void
			name_not_empty: not a_root_name.is_empty
		local
			l_ns: XM_NAMESPACE
		do
			create l_ns.make_default
			create xm_document.make_with_root_named (a_root_name, l_ns)
			if attached xm_document as l_doc then
				create root_element.make_from_xm_element (l_doc.root_element)
			end
			is_valid := True
			create error_message.make_empty
		ensure
			is_valid: is_valid
			root_name_set: attached root as r implies r.name.same_string (a_root_name)
		end

	make_with_error (a_error: STRING)
			-- Create invalid document with error message.
		require
			error_not_void: a_error /= Void
		do
			is_valid := False
			error_message := a_error
		ensure
			not_valid: not is_valid
			error_set: error_message.same_string (a_error)
		end

feature -- Status

	is_valid: BOOLEAN
			-- Was document parsed successfully?

	has_error: BOOLEAN
			-- Did parsing fail?
		do
			Result := not is_valid
		ensure
			definition: Result = not is_valid
		end

	error_message: STRING
			-- Error description if parsing failed.

feature -- Access

	root: detachable SIMPLE_XML_ELEMENT
			-- Root element of document.
		do
			Result := root_element
		end

feature -- Navigation (Direct API)

	text_at (a_path: READABLE_STRING_GENERAL): STRING
			-- Text content at `a_path', or empty string if not found.
			-- Path format: "root/child/grandchild"
		require
			path_not_void: a_path /= Void
			is_valid: is_valid
		do
			if attached element_at (a_path) as l_elem then
				Result := l_elem.text
			else
				create Result.make_empty
			end
		ensure
			result_attached: Result /= Void
		end

	attr_at (a_path: READABLE_STRING_GENERAL; a_attr_name: READABLE_STRING_GENERAL): detachable STRING
			-- Attribute value at element `a_path' with attribute name `a_attr_name'.
			-- Returns Void if element or attribute not found.
		require
			path_not_void: a_path /= Void
			attr_name_not_void: a_attr_name /= Void
			is_valid: is_valid
		do
			if attached element_at (a_path) as l_elem then
				Result := l_elem.attr (a_attr_name.to_string_8)
			end
		end

	element_at (a_path: READABLE_STRING_GENERAL): detachable SIMPLE_XML_ELEMENT
			-- Element at `a_path', or Void if not found.
			-- Path format: "root/child/grandchild"
		require
			path_not_void: a_path /= Void
			is_valid: is_valid
		local
			l_parts: LIST [STRING]
			l_current: detachable SIMPLE_XML_ELEMENT
			i: INTEGER
		do
			l_parts := a_path.to_string_8.split ('/')
			-- Remove empty parts (leading/trailing slashes)
			from l_parts.start until l_parts.after loop
				if l_parts.item.is_empty then
					l_parts.remove
				else
					l_parts.forth
				end
			end

			if l_parts.count > 0 then
				l_current := root_element
				-- Skip root element name if it matches first part
				i := 1
				if attached l_current as lc and then lc.name.same_string (l_parts.i_th (1)) then
					i := 2
				end
				-- Navigate through path
				from until i > l_parts.count or l_current = Void loop
					if attached l_current as lc then
						l_current := lc.element (l_parts.i_th (i))
					end
					i := i + 1
				end
				Result := l_current
			end
		end

	elements_at (a_path: READABLE_STRING_GENERAL): ARRAYED_LIST [SIMPLE_XML_ELEMENT]
			-- All elements matching `a_path'.
			-- Last segment can match multiple elements.
		require
			path_not_void: a_path /= Void
			is_valid: is_valid
		local
			l_parts: LIST [STRING]
			l_parent_path: STRING
			l_element_name: STRING
		do
			create Result.make (10)
			l_parts := a_path.to_string_8.split ('/')
			-- Remove empty parts
			from l_parts.start until l_parts.after loop
				if l_parts.item.is_empty then
					l_parts.remove
				else
					l_parts.forth
				end
			end

			if l_parts.count > 0 then
				l_element_name := l_parts.last
				if l_parts.count = 1 then
					-- Just root level
					if attached root_element as r and then r.name.same_string (l_element_name) then
						Result.extend (r)
					elseif attached root_element as r then
						Result := r.elements (l_element_name)
					end
				else
					-- Build parent path
					create l_parent_path.make_empty
					across 1 |..| (l_parts.count - 1) as ic loop
						if not l_parent_path.is_empty then
							l_parent_path.append_character ('/')
						end
						l_parent_path.append (l_parts.i_th (ic))
					end
					if attached element_at (l_parent_path) as l_parent then
						Result := l_parent.elements (l_element_name)
					end
				end
			end
		ensure
			result_attached: Result /= Void
		end

feature -- Serialization

	to_string: STRING
			-- XML as compact string.
		require
			is_valid: is_valid
		do
			if attached xm_document as l_doc then
				Result := document_to_string (l_doc, False)
			else
				create Result.make_empty
			end
		ensure
			result_attached: Result /= Void
		end

	to_pretty_string: STRING
			-- XML as indented string.
		require
			is_valid: is_valid
		do
			if attached xm_document as l_doc then
				Result := document_to_string (l_doc, True)
			else
				create Result.make_empty
			end
		ensure
			result_attached: Result /= Void
		end

	save_to_file (a_path: READABLE_STRING_GENERAL)
			-- Save XML to file at `a_path'.
		require
			path_not_void: a_path /= Void
			is_valid: is_valid
		local
			l_file: PLAIN_TEXT_FILE
		do
			create l_file.make_create_read_write (a_path.to_string_8)
			l_file.put_string (to_pretty_string)
			l_file.close
		end

feature {NONE} -- Implementation

	xm_document: detachable XM_DOCUMENT
			-- Underlying Gobo XML document.

	root_element: detachable SIMPLE_XML_ELEMENT
			-- Wrapped root element.

	document_to_string (a_doc: XM_DOCUMENT; a_pretty: BOOLEAN): STRING
			-- Convert document to string.
		local
			l_formatter: XM_FORMATTER
			l_stream: KL_STRING_OUTPUT_STREAM
			l_pretty_filter: XM_INDENT_PRETTY_PRINT_FILTER
			l_xmlns: XM_XMLNS_GENERATOR
		do
			create Result.make (1024)
			create l_stream.make (Result)
			if a_pretty then
				-- Use indented pretty print filter
				create l_pretty_filter.make_null
				l_pretty_filter.set_output_stream (l_stream)
				create l_xmlns.make_next (l_pretty_filter)
				a_doc.process_to_events (l_xmlns)
			else
				-- Use standard formatter
				create l_formatter.make
				l_formatter.set_output (l_stream)
				a_doc.process (l_formatter)
			end
		end

invariant
	valid_implies_root: is_valid implies root_element /= Void
	invalid_implies_error: not is_valid implies not error_message.is_empty

end
