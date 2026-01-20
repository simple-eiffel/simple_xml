note
	description: "[
		XML element with navigation and manipulation features.

		Navigation (fluent):
			item := root.element ("items").element ("item")
			items := root.element ("items").elements ("item")
			value := item.text
			id := item.attr ("id")

		Modification:
			item.set_text ("new value")
			item.set_attr ("id", "123")
			item.add_element ("child").set_text ("content")

		Access:
			name := element.name
			text := element.text
			attrs := element.attributes
			children := element.elements
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_XML_ELEMENT

create
	make_from_xm_element

feature {NONE} -- Initialization

	make_from_xm_element (a_element: XM_ELEMENT)
			-- Create wrapper for `a_element'.
		require
			element_not_void: a_element /= Void
		do
			xm_element := a_element
		ensure
			element_set: xm_element = a_element
		end

feature -- Access

	name: STRING
			-- Element tag name.
		do
			Result := xm_element.name
		ensure
			result_attached: Result /= Void
		end

	text: STRING
			-- Combined text content of element (all text children).
		local
			l_cursor: DS_LINEAR_CURSOR [XM_NODE]
		do
			create Result.make (100)
			l_cursor := xm_element.new_cursor
			from l_cursor.start until l_cursor.after loop
				if attached {XM_CHARACTER_DATA} l_cursor.item as l_text then
					Result.append (l_text.content)
				end
				l_cursor.forth
			end
		ensure
			result_attached: Result /= Void
		end

	inner_xml: STRING
			-- All content as XML string (elements and text).
		local
			l_cursor: DS_LINEAR_CURSOR [XM_NODE]
		do
			create Result.make (256)
			l_cursor := xm_element.new_cursor
			from l_cursor.start until l_cursor.after loop
				if attached {XM_CHARACTER_DATA} l_cursor.item as l_text then
					Result.append (escape_xml (l_text.content))
				elseif attached {XM_ELEMENT} l_cursor.item as l_elem then
					Result.append (element_to_string (l_elem))
				end
				l_cursor.forth
			end
		ensure
			result_attached: Result /= Void
		end

feature -- Attribute Access

	attr (a_name: READABLE_STRING_GENERAL): detachable STRING
			-- Value of attribute named `a_name', or Void if not found.
		require
			name_not_void: a_name /= Void
		do
			if attached xm_element.attribute_by_name (a_name.to_string_8) as l_attr then
				Result := l_attr.value
			end
		end

	has_attr (a_name: READABLE_STRING_GENERAL): BOOLEAN
			-- Does element have attribute named `a_name'?
		require
			name_not_void: a_name /= Void
		do
			Result := xm_element.has_attribute_by_name (a_name.to_string_8)
		end

	attributes: HASH_TABLE [STRING, STRING]
			-- All attributes as name-value pairs.
		local
			l_attrs: DS_LIST [XM_ATTRIBUTE]
			l_cursor: DS_LINEAR_CURSOR [XM_ATTRIBUTE]
		do
			l_attrs := xm_element.attributes
			create Result.make (l_attrs.count)
			l_cursor := l_attrs.new_cursor
			from l_cursor.start until l_cursor.after loop
				Result.force (l_cursor.item.value, l_cursor.item.name)
				l_cursor.forth
			end
		ensure
			result_attached: Result /= Void
		end

feature -- Child Element Access

	element (a_name: READABLE_STRING_GENERAL): detachable SIMPLE_XML_ELEMENT
			-- First direct child element named `a_name', or Void if not found.
		require
			name_not_void: a_name /= Void
		do
			if attached xm_element.element_by_name (a_name.to_string_8) as l_elem then
				create Result.make_from_xm_element (l_elem)
			end
		end

	elements (a_name: READABLE_STRING_GENERAL): ARRAYED_LIST [SIMPLE_XML_ELEMENT]
			-- All direct child elements named `a_name'.
		require
			name_not_void: a_name /= Void
		local
			l_cursor: DS_LINEAR_CURSOR [XM_NODE]
		do
			create Result.make (10)
			l_cursor := xm_element.new_cursor
			from l_cursor.start until l_cursor.after loop
				if attached {XM_ELEMENT} l_cursor.item as l_elem then
					if l_elem.name.same_string (a_name.to_string_8) then
						Result.extend (create {SIMPLE_XML_ELEMENT}.make_from_xm_element (l_elem))
					end
				end
				l_cursor.forth
			end
		ensure
			result_attached: Result /= Void
		end

	all_elements: ARRAYED_LIST [SIMPLE_XML_ELEMENT]
			-- All direct child elements.
		local
			l_cursor: DS_LINEAR_CURSOR [XM_NODE]
		do
			create Result.make (10)
			l_cursor := xm_element.new_cursor
			from l_cursor.start until l_cursor.after loop
				if attached {XM_ELEMENT} l_cursor.item as l_elem then
					Result.extend (create {SIMPLE_XML_ELEMENT}.make_from_xm_element (l_elem))
				end
				l_cursor.forth
			end
		ensure
			result_attached: Result /= Void
		end

	has_element (a_name: READABLE_STRING_GENERAL): BOOLEAN
			-- Does element have direct child named `a_name'?
		require
			name_not_void: a_name /= Void
		do
			Result := xm_element.has_element_by_name (a_name.to_string_8)
		end

feature -- Navigation (Fluent)

	text_at (a_path: READABLE_STRING_GENERAL): STRING
			-- Text content at relative path `a_path'.
		require
			path_not_void: a_path /= Void
		do
			if attached element_at (a_path) as l_elem then
				Result := l_elem.text
			else
				create Result.make_empty
			end
		ensure
			result_attached: Result /= Void
		end

	element_at (a_path: READABLE_STRING_GENERAL): detachable SIMPLE_XML_ELEMENT
			-- Element at relative path `a_path'.
		require
			path_not_void: a_path /= Void
		local
			l_parts: LIST [STRING]
			l_current: detachable SIMPLE_XML_ELEMENT
			i: INTEGER
		do
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
				l_current := Current
				from i := 1 until i > l_parts.count or l_current = Void loop
					if attached l_current as lc then
						l_current := lc.element (l_parts.i_th (i))
					end
					i := i + 1
				end
				Result := l_current
			end
		end

feature -- Parent Access

	parent: detachable SIMPLE_XML_ELEMENT
			-- Parent element, or Void if root.
		do
			if attached {XM_ELEMENT} xm_element.parent as l_parent_elem then
				create Result.make_from_xm_element (l_parent_elem)
			end
		end

feature -- Modification

	set_text (a_text: READABLE_STRING_GENERAL): like Current
			-- Set text content to `a_text'.
			-- Returns Current for fluent chaining.
		require
			text_not_void: a_text /= Void
		local
			l_to_remove: ARRAYED_LIST [XM_CHARACTER_DATA]
			l_cursor: DS_LINEAR_CURSOR [XM_NODE]
			l_text: XM_CHARACTER_DATA
		do
			-- Collect text nodes to remove (can't modify during iteration)
			create l_to_remove.make (5)
			l_cursor := xm_element.new_cursor
			from l_cursor.start until l_cursor.after loop
				if attached {XM_CHARACTER_DATA} l_cursor.item as l_char_data then
					l_to_remove.extend (l_char_data)
				end
				l_cursor.forth
			end
			-- Remove collected nodes
			across l_to_remove as ic loop
				xm_element.delete (ic)
			end
			-- Add new text
			create l_text.make (xm_element, a_text.to_string_8)
			xm_element.force_last (l_text)
			Result := Current
		ensure
			text_set: text.same_string (a_text.to_string_8)
			fluent: Result = Current
		end

	set_attr (a_name: READABLE_STRING_GENERAL; a_value: READABLE_STRING_GENERAL): like Current
			-- Set attribute `a_name' to `a_value'.
			-- Returns Current for fluent chaining.
		require
			name_not_void: a_name /= Void
			value_not_void: a_value /= Void
		do
			if xm_element.has_attribute_by_name (a_name.to_string_8) then
				xm_element.remove_attribute_by_name (a_name.to_string_8)
			end
			xm_element.add_unqualified_attribute (a_name.to_string_8, a_value.to_string_8)
			Result := Current
		ensure
			attr_set: attached attr (a_name) as v and then v.same_string (a_value.to_string_8)
			fluent: Result = Current
		end

	remove_attr (a_name: READABLE_STRING_GENERAL): like Current
			-- Remove attribute named `a_name'.
			-- Returns Current for fluent chaining.
		require
			name_not_void: a_name /= Void
		do
			if xm_element.has_attribute_by_name (a_name.to_string_8) then
				xm_element.remove_attribute_by_name (a_name.to_string_8)
			end
			Result := Current
		ensure
			attr_removed: not has_attr (a_name)
			fluent: Result = Current
		end

	add_element (a_name: READABLE_STRING_GENERAL): SIMPLE_XML_ELEMENT
			-- Add new child element named `a_name'.
			-- Returns new element for fluent chaining.
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
		local
			l_ns: XM_NAMESPACE
			l_elem: XM_ELEMENT
		do
			create l_ns.make_default
			create l_elem.make_last (xm_element, a_name.to_string_8, l_ns)
			create Result.make_from_xm_element (l_elem)
		ensure
			result_attached: Result /= Void
			element_added: has_element (a_name)
		end

feature {SIMPLE_XML_ELEMENT, SIMPLE_XML_DOCUMENT, SIMPLE_XML_BUILDER} -- Implementation

	xm_element: XM_ELEMENT
			-- Underlying Gobo XML element.

feature {NONE} -- Implementation

	escape_xml (a_text: STRING): STRING
			-- Escape XML special characters in `a_text' using SIMPLE_ZSTRING_ESCAPER.
		local
			l_escaper: SIMPLE_ZSTRING_ESCAPER
		do
			create l_escaper
			Result := l_escaper.escape_xml (a_text).to_string_8
		end

	element_to_string (a_elem: XM_ELEMENT): STRING
			-- Convert element to XML string.
		local
			l_wrapper: SIMPLE_XML_ELEMENT
			l_attrs: HASH_TABLE [STRING, STRING]
		do
			create l_wrapper.make_from_xm_element (a_elem)
			create Result.make (100)
			Result.append_character ('<')
			Result.append (a_elem.name)
			-- Add attributes (use ic_attr to avoid conflict with `attr' feature)
			l_attrs := l_wrapper.attributes
			across l_attrs as ic_attr loop
				Result.append_character (' ')
				Result.append (@ic_attr.key)
				Result.append ("=%"")
				Result.append (escape_xml (ic_attr))
				Result.append_character ('"')
			end
			-- Check for content
			if l_wrapper.inner_xml.is_empty then
				Result.append ("/>")
			else
				Result.append_character ('>')
				Result.append (l_wrapper.inner_xml)
				Result.append ("</")
				Result.append (a_elem.name)
				Result.append_character ('>')
			end
		end

invariant
	element_attached: xm_element /= Void

end
