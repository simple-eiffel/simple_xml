note
	description: "[
		Fluent XML document builder.

		Usage:
			doc := xml.build ("root")
			         .element ("item").attr ("id", "1").text ("value").done
			         .element ("item").attr ("id", "2").text ("other").done
			       .to_document

		Or nested:
			doc := xml.build ("config")
			         .element ("database")
			           .element ("host").text ("localhost").done
			           .element ("port").text ("5432").done
			         .done
			       .to_document

		Model Queries (for contracts):
			nesting_depth: INTEGER -- Current nesting level (0 = at root)
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_XML_BUILDER

create
	make

feature {NONE} -- Initialization

	make (a_root_name: STRING)
			-- Create builder with root element named `a_root_name'.
		require
			name_not_empty: not a_root_name.is_empty
		local
			l_ns: XM_NAMESPACE
		do
			create l_ns.make_default
			create xm_document.make_with_root_named (a_root_name, l_ns)
			current_element := xm_document.root_element
			create element_stack.make (10)
		ensure
			document_created: xm_document /= Void
			at_root: current_element = xm_document.root_element
		end

feature -- Building (Fluent)

	element (a_name: READABLE_STRING_GENERAL): like Current
			-- Add child element named `a_name' and move into it.
			-- Use `done' to return to parent.
		require
			name_not_empty: not a_name.is_empty
		local
			l_ns: XM_NAMESPACE
			l_elem: XM_ELEMENT
		do
			-- Push current to stack
			element_stack.extend (current_element)
			-- Create and move to new element
			create l_ns.make_default
			create l_elem.make_last (current_element, a_name.to_string_8, l_ns)
			current_element := l_elem
			Result := Current
		ensure
			fluent: Result = Current
			moved_into_element: current_element.name.same_string (a_name.to_string_8)
			depth_increased: nesting_depth = old nesting_depth + 1
		end

	attr (a_name: READABLE_STRING_GENERAL; a_value: READABLE_STRING_GENERAL): like Current
			-- Add attribute to current element.
		do
			current_element.add_unqualified_attribute (a_name.to_string_8, a_value.to_string_8)
			Result := Current
		ensure
			fluent: Result = Current
			attr_added: current_element.has_attribute_by_name (a_name.to_string_8)
		end

	text (a_text: READABLE_STRING_GENERAL): like Current
			-- Set text content of current element.
		local
			l_text: XM_CHARACTER_DATA
		do
			create l_text.make (current_element, a_text.to_string_8)
			current_element.force_last (l_text)
			Result := Current
		ensure
			fluent: Result = Current
		end

	is_at_root: BOOLEAN
			-- Is builder at root element (no parent to return to)?
		do
			Result := element_stack.is_empty
		ensure
			definition: Result = (nesting_depth = 0)
		end

feature -- Model Queries (for contracts)

	nesting_depth: INTEGER
			-- Current nesting depth (0 = at root).
		do
			Result := element_stack.count
		ensure
			non_negative: Result >= 0
		end

feature -- Building (Fluent continued)

	done: like Current
			-- Finish current element and return to parent.
		require
			not_at_root: not is_at_root
		do
			current_element := element_stack.item
			element_stack.remove
			Result := Current
		ensure
			fluent: Result = Current
			depth_decreased: nesting_depth = old nesting_depth - 1
		end

	comment (a_text: READABLE_STRING_GENERAL): like Current
			-- Add XML comment to current element.
		local
			l_comment: XM_COMMENT
		do
			create l_comment.make (current_element, a_text.to_string_8)
			current_element.force_last (l_comment)
			Result := Current
		ensure
			fluent: Result = Current
		end

feature -- Conversion

	to_document: SIMPLE_XML_DOCUMENT
			-- Build and return the document.
		do
			create Result.make_from_xm_document (xm_document)
		ensure
			result_attached: Result /= Void
			result_valid: Result.is_valid
		end

	to_string: STRING
			-- Build and return XML as string.
		do
			Result := to_document.to_string
		ensure
			result_attached: Result /= Void
		end

	to_pretty_string: STRING
			-- Build and return XML as indented string.
		do
			Result := to_document.to_pretty_string
		ensure
			result_attached: Result /= Void
		end

feature {NONE} -- Implementation

	xm_document: XM_DOCUMENT
			-- Document being built.

	current_element: XM_ELEMENT
			-- Current element (where new content is added).

	element_stack: ARRAYED_STACK [XM_ELEMENT]
			-- Stack of parent elements for nested building.

invariant
	document_attached: xm_document /= Void
	current_attached: current_element /= Void
	stack_attached: element_stack /= Void

end