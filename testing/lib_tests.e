note
	description: "Test set for simple_xml"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	LIB_TESTS

inherit
	TEST_SET_BASE

feature -- Test: Parsing

	test_parse_simple
			-- Test basic XML parsing.
			-- Coverage: SIMPLE_XML.parse, SIMPLE_XML_DOCUMENT.is_valid, root, name
		local
			l_xml: SIMPLE_XML
			l_doc: SIMPLE_XML_DOCUMENT
		do
			create l_xml.make
			l_doc := l_xml.parse ("<root><item>value</item></root>")
			assert ("is_valid", l_doc.is_valid)
			assert ("has_root", attached l_doc.root)
			assert ("root_name", attached l_doc.root as r and then r.name.same_string ("root"))
		end

	test_parse_error
			-- Test error handling for invalid XML.
			-- Coverage: SIMPLE_XML_DOCUMENT.has_error, error_message
		local
			l_xml: SIMPLE_XML
			l_doc: SIMPLE_XML_DOCUMENT
		do
			create l_xml.make
			l_doc := l_xml.parse ("<root><unclosed>")
			assert ("not_valid", not l_doc.is_valid)
			assert ("has_error", l_doc.has_error)
			assert ("error_message", not l_doc.error_message.is_empty)
		end

feature -- Test: Navigation

	test_text_at
			-- Test text_at navigation.
			-- Coverage: SIMPLE_XML_DOCUMENT.text_at with deep paths
		local
			l_xml: SIMPLE_XML
			l_doc: SIMPLE_XML_DOCUMENT
		do
			create l_xml.make
			l_doc := l_xml.parse ("<config><database><host>localhost</host><port>5432</port></database></config>")
			assert ("is_valid", l_doc.is_valid)
			assert ("host_text", l_doc.text_at ("config/database/host").same_string ("localhost"))
			assert ("port_text", l_doc.text_at ("config/database/port").same_string ("5432"))
			assert ("not_found", l_doc.text_at ("config/nonexistent").is_empty)
		end

	test_attr_at
			-- Test attr_at navigation.
			-- Coverage: SIMPLE_XML_DOCUMENT.attr_at, SIMPLE_XML_ELEMENT.attr
		local
			l_xml: SIMPLE_XML
			l_doc: SIMPLE_XML_DOCUMENT
		do
			create l_xml.make
			l_doc := l_xml.parse ("<root><item id=%"123%" type=%"test%">value</item></root>")
			assert ("is_valid", l_doc.is_valid)
			assert ("id_attr", attached l_doc.attr_at ("root/item", "id") as v and then v.same_string ("123"))
			assert ("type_attr", attached l_doc.attr_at ("root/item", "type") as v and then v.same_string ("test"))
			assert ("not_found", l_doc.attr_at ("root/item", "missing") = Void)
		end

	test_elements_at
			-- Test elements_at for multiple matches.
			-- Coverage: SIMPLE_XML_DOCUMENT.elements_at, SIMPLE_XML_ELEMENT.text
		local
			l_xml: SIMPLE_XML
			l_doc: SIMPLE_XML_DOCUMENT
			l_items: ARRAYED_LIST [SIMPLE_XML_ELEMENT]
		do
			create l_xml.make
			l_doc := l_xml.parse ("<root><items><item>one</item><item>two</item><item>three</item></items></root>")
			assert ("is_valid", l_doc.is_valid)
			l_items := l_doc.elements_at ("root/items/item")
			assert ("three_items", l_items.count = 3)
			assert ("first_item", l_items.first.text.same_string ("one"))
			assert ("last_item", l_items.last.text.same_string ("three"))
		end

	test_element_navigation
			-- Test fluent element navigation.
			-- Coverage: SIMPLE_XML_ELEMENT.element (fluent chaining)
		local
			l_xml: SIMPLE_XML
			l_doc: SIMPLE_XML_DOCUMENT
		do
			create l_xml.make
			l_doc := l_xml.parse ("<root><level1><level2><level3>deep</level3></level2></level1></root>")
			assert ("is_valid", l_doc.is_valid)
			if attached l_doc.root as r then
				assert ("fluent_nav", attached r.element ("level1") as l1 and then
					attached l1.element ("level2") as l2 and then
					attached l2.element ("level3") as l3 and then
					l3.text.same_string ("deep"))
			else
				assert ("has_root", False)
			end
		end

feature -- Test: Building

	test_builder_simple
			-- Test simple builder usage.
			-- Coverage: SIMPLE_XML.build, SIMPLE_XML_BUILDER.element, attr, text, done, to_document
		local
			l_xml: SIMPLE_XML
			l_doc: SIMPLE_XML_DOCUMENT
		do
			create l_xml.make
			l_doc := l_xml.build ("root")
				.element ("item").attr ("id", "1").text ("value").done
				.to_document
			assert ("is_valid", l_doc.is_valid)
			assert ("has_item", attached l_doc.root as r and then r.has_element ("item"))
			assert ("item_text", l_doc.text_at ("root/item").same_string ("value"))
			assert ("item_attr", attached l_doc.attr_at ("root/item", "id") as v and then v.same_string ("1"))
		end

	test_builder_nested
			-- Test nested builder usage.
			-- Coverage: SIMPLE_XML_BUILDER with multi-level nesting
		local
			l_xml: SIMPLE_XML
			l_doc: SIMPLE_XML_DOCUMENT
		do
			create l_xml.make
			l_doc := l_xml.build ("config")
				.element ("database")
					.element ("host").text ("localhost").done
					.element ("port").text ("5432").done
				.done
				.to_document
			assert ("is_valid", l_doc.is_valid)
			assert ("host", l_doc.text_at ("config/database/host").same_string ("localhost"))
			assert ("port", l_doc.text_at ("config/database/port").same_string ("5432"))
		end

feature -- Test: Modification

	test_modification
			-- Test element modification.
			-- Coverage: SIMPLE_XML_ELEMENT.set_text, set_attr (fluent), attr (query)
		local
			l_xml: SIMPLE_XML
			l_doc: SIMPLE_XML_DOCUMENT
			l_item: SIMPLE_XML_ELEMENT
		do
			create l_xml.make
			l_doc := l_xml.parse ("<root><item id=%"1%">old</item></root>")
			assert ("is_valid", l_doc.is_valid)
			if attached l_doc.root as r and then attached r.element ("item") as item then
				-- Fluent functions return Current, so chain them or capture result
				l_item := item.set_text ("new").set_attr ("id", "2").set_attr ("added", "yes")
				assert ("text_changed", l_item.text.same_string ("new"))
				assert ("attr_changed", attached l_item.attr ("id") as v and then v.same_string ("2"))
				assert ("attr_added", attached l_item.attr ("added") as v and then v.same_string ("yes"))
			else
				assert ("has_item", False)
			end
		end

feature -- Test: Serialization

	test_to_string
			-- Test serialization to string.
			-- Coverage: SIMPLE_XML_DOCUMENT.to_string
		local
			l_xml: SIMPLE_XML
			l_doc: SIMPLE_XML_DOCUMENT
			l_output: STRING
		do
			create l_xml.make
			l_doc := l_xml.build ("root")
				.element ("item").text ("value").done
				.to_document
			assert ("is_valid", l_doc.is_valid)
			l_output := l_doc.to_string
			assert ("has_root", l_output.has_substring ("<root"))
			assert ("has_item", l_output.has_substring ("<item"))
			assert ("has_value", l_output.has_substring ("value"))
		end

feature -- Test: Quick API

	test_quick_xpath
			-- Test SIMPLE_XML_QUICK.xpath.
			-- Coverage: xpath feature with path query
		local
			l_quick: SIMPLE_XML_QUICK
			l_results: ARRAYED_LIST [STRING]
		do
			create l_quick.make
			l_results := l_quick.xpath ("<root><items><item>one</item><item>two</item></items></root>", "root/items/item")
			assert ("two_results", l_results.count = 2)
			assert ("first_is_one", l_results.first.same_string ("one"))
			assert ("second_is_two", l_results.i_th (2).same_string ("two"))
		end

	test_quick_first
			-- Test SIMPLE_XML_QUICK.first.
			-- Coverage: first feature returns first match
		local
			l_quick: SIMPLE_XML_QUICK
		do
			create l_quick.make
			assert ("first_result", attached l_quick.first ("<root><item>value</item></root>", "root/item") as v and then v.same_string ("value"))
			assert ("no_match", l_quick.first ("<root><item>value</item></root>", "root/missing") = Void)
		end

	test_quick_attr
			-- Test SIMPLE_XML_QUICK.attr.
			-- Coverage: attr feature gets attribute from first match
		local
			l_quick: SIMPLE_XML_QUICK
		do
			create l_quick.make
			assert ("attr_found", attached l_quick.attr ("<root><item id=%"123%">value</item></root>", "root/item", "id") as v and then v.same_string ("123"))
			assert ("attr_missing", l_quick.attr ("<root><item id=%"123%">value</item></root>", "root/item", "missing") = Void)
		end

	test_quick_count
			-- Test SIMPLE_XML_QUICK.count.
			-- Coverage: count feature counts matches
		local
			l_quick: SIMPLE_XML_QUICK
		do
			create l_quick.make
			assert ("count_3", l_quick.count ("<root><item>1</item><item>2</item><item>3</item></root>", "root/item") = 3)
			assert ("count_0", l_quick.count ("<root><item>1</item></root>", "root/missing") = 0)
		end

	test_quick_exists
			-- Test SIMPLE_XML_QUICK.exists.
			-- Coverage: exists feature checks for any match
		local
			l_quick: SIMPLE_XML_QUICK
		do
			create l_quick.make
			assert ("exists_true", l_quick.exists ("<root><item>value</item></root>", "root/item"))
			assert ("exists_false", not l_quick.exists ("<root><item>value</item></root>", "root/missing"))
		end

feature -- Test: File Parsing

	test_parse_file_with_utf8_bom
			-- Test that files with UTF-8 BOM are parsed correctly.
			-- Coverage: SIMPLE_XML.parse_file with BOM stripping
		local
			l_xml: SIMPLE_XML
			l_doc: SIMPLE_XML_DOCUMENT
			l_file: PLAIN_TEXT_FILE
			l_path: STRING
			l_content: STRING_8
		do
			l_path := "test_bom_temp.xml"
			-- Create XML file with UTF-8 BOM prefix
			create l_content.make (50)
			l_content.append_character ('%/239/')  -- 0xEF
			l_content.append_character ('%/187/')  -- 0xBB
			l_content.append_character ('%/191/')  -- 0xBF
			l_content.append ("<root><item>test</item></root>")
			create l_file.make_create_read_write (l_path)
			l_file.put_string (l_content)
			l_file.close
			-- Parse and verify
			create l_xml.make
			l_doc := l_xml.parse_file (l_path)
			assert ("bom_parsed", l_doc.is_valid)
			assert ("has_root", attached l_doc.root as r and then r.name.same_string ("root"))
			assert ("item_text", l_doc.text_at ("root/item").same_string ("test"))
			-- Clean up
			create l_file.make_with_name (l_path)
			if l_file.exists then
				l_file.delete
			end
		end

feature -- Test: Serializer

	test_serializer_basic
			-- Test basic XML serializer functionality.
			-- Coverage: SIMPLE_XML_SERIALIZER.serialize
		local
			l_serializer: SIMPLE_XML_SERIALIZER
			l_xml: STRING
		do
			create l_serializer.make
			-- Test with a basic object (self)
			l_xml := l_serializer.serialize (Current)
			assert ("has_xml_output", not l_xml.is_empty)
			assert ("has_root_element", l_xml.has_substring ("lib_tests"))
			assert ("has_class_attr", l_xml.has_substring ("_class"))
		end

	test_serializer_settings
			-- Test serializer settings.
			-- Coverage: SIMPLE_XML_SERIALIZER settings
		local
			l_serializer: SIMPLE_XML_SERIALIZER
		do
			create l_serializer.make
			-- Default settings
			assert ("class_attr_default", l_serializer.include_class_attribute)
			assert ("primitives_default", not l_serializer.use_attribute_for_primitives)

			-- Change settings
			l_serializer.set_include_class_attribute (False)
			l_serializer.set_use_attribute_for_primitives (True)
			assert ("class_attr_changed", not l_serializer.include_class_attribute)
			assert ("primitives_changed", l_serializer.use_attribute_for_primitives)
		end

end
