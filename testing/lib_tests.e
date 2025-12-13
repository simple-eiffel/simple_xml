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

end
