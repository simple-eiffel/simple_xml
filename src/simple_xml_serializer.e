note
	description: "Reflection-based XML serializer for automatic object-to-XML conversion"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_XML_SERIALIZER

create
	make

feature {NONE} -- Initialization

	make
			-- Create XML serializer.
		do
			include_class_attribute := True
			use_attribute_for_primitives := False
		end

feature -- Settings

	include_class_attribute: BOOLEAN
			-- Include "_class" attribute in root element?

	use_attribute_for_primitives: BOOLEAN
			-- Use XML attributes for primitive types instead of child elements?

	set_include_class_attribute (a_value: BOOLEAN)
			-- Set whether to include "_class" attribute.
		do
			include_class_attribute := a_value
		ensure
			set: include_class_attribute = a_value
		end

	set_use_attribute_for_primitives (a_value: BOOLEAN)
			-- Set whether to use XML attributes for primitives.
		do
			use_attribute_for_primitives := a_value
		ensure
			set: use_attribute_for_primitives = a_value
		end

feature -- Serialization

	serialize (a_object: ANY): STRING
			-- Serialize `a_object` to XML string.
		require
			object_exists: a_object /= Void
		local
			l_builder: SIMPLE_XML_BUILDER
			l_root_name: STRING
			l_ignore: SIMPLE_XML_BUILDER
		do
			l_root_name := object_element_name (a_object)
			create l_builder.make (l_root_name)
			if include_class_attribute then
				l_ignore := l_builder.attr ("_class", a_object.generator)
			end
			serialize_object_fields (a_object, l_builder)
			Result := l_builder.to_string
		ensure
			result_not_empty: not Result.is_empty
		end

	serialize_pretty (a_object: ANY): STRING
			-- Serialize `a_object` to formatted XML string.
		require
			object_exists: a_object /= Void
		do
			Result := serialize (a_object)
			-- Note: Pretty printing would require additional formatting
			-- For now, returns same as serialize
		ensure
			result_not_empty: not Result.is_empty
		end

feature {NONE} -- Implementation

	serialize_object_fields (a_object: ANY; a_builder: SIMPLE_XML_BUILDER)
			-- Serialize all fields of `a_object` into `a_builder`.
		local
			l_reflected: SIMPLE_REFLECTED_OBJECT
			l_field: SIMPLE_FIELD_INFO
			l_value: detachable ANY
			i: INTEGER
		do
			create l_reflected.make (a_object)
			from
				i := 1
			until
				i > l_reflected.type_info.fields.count
			loop
				l_field := l_reflected.type_info.fields [i]
				l_value := l_field.value (a_object)
				serialize_field (l_field.name.to_string_8, l_value, a_builder)
				i := i + 1
			end
		end

	serialize_field (a_name: STRING; a_value: detachable ANY; a_builder: SIMPLE_XML_BUILDER)
			-- Serialize field with `a_name` and `a_value` into `a_builder`.
		local
			l_ignore: SIMPLE_XML_BUILDER
		do
			if a_value = Void then
				-- Skip null values (or could add xsi:nil="true")
			elseif attached {READABLE_STRING_GENERAL} a_value as l_str then
				if use_attribute_for_primitives then
					l_ignore := a_builder.attr (a_name, l_str.to_string_8)
				else
					l_ignore := a_builder.element (a_name).text (l_str.to_string_8).done
				end
			elseif attached {INTEGER_REF} a_value as l_int then
				if use_attribute_for_primitives then
					l_ignore := a_builder.attr (a_name, l_int.item.out)
				else
					l_ignore := a_builder.element (a_name).text (l_int.item.out).done
				end
			elseif attached {BOOLEAN_REF} a_value as l_bool then
				if use_attribute_for_primitives then
					l_ignore := a_builder.attr (a_name, l_bool.item.out.as_lower)
				else
					l_ignore := a_builder.element (a_name).text (l_bool.item.out.as_lower).done
				end
			elseif attached {REAL_64_REF} a_value as l_real then
				if use_attribute_for_primitives then
					l_ignore := a_builder.attr (a_name, l_real.item.out)
				else
					l_ignore := a_builder.element (a_name).text (l_real.item.out).done
				end
			elseif attached {ITERABLE [ANY]} a_value as l_list then
				l_ignore := a_builder.element (a_name)
				serialize_list (l_list, a_builder)
				l_ignore := a_builder.done
			else
				-- Complex object - nested element
				l_ignore := a_builder.element (a_name)
				serialize_object_fields (a_value, a_builder)
				l_ignore := a_builder.done
			end
		end

	serialize_list (a_list: ITERABLE [ANY]; a_builder: SIMPLE_XML_BUILDER)
			-- Serialize list items into `a_builder`.
		local
			l_item_name: STRING
			l_ignore: SIMPLE_XML_BUILDER
		do
			across a_list as ic loop
				if attached ic as l_item then
					l_item_name := "item"
					if attached {READABLE_STRING_GENERAL} l_item as l_str then
						l_ignore := a_builder.element (l_item_name).text (l_str.to_string_8).done
					elseif attached {INTEGER_REF} l_item as l_int then
						l_ignore := a_builder.element (l_item_name).text (l_int.item.out).done
					elseif attached {BOOLEAN_REF} l_item as l_bool then
						l_ignore := a_builder.element (l_item_name).text (l_bool.item.out.as_lower).done
					elseif attached {REAL_64_REF} l_item as l_real then
						l_ignore := a_builder.element (l_item_name).text (l_real.item.out).done
					else
						l_ignore := a_builder.element (l_item_name)
						serialize_object_fields (l_item, a_builder)
						l_ignore := a_builder.done
					end
				end
			end
		end

	object_element_name (a_object: ANY): STRING
			-- Get element name for object (lowercase type name).
		do
			Result := a_object.generator.as_lower
		ensure
			not_empty: not Result.is_empty
		end

note
	copyright: "Copyright (c) 2024-2025, Larry Rix"
	license: "MIT License"

end
