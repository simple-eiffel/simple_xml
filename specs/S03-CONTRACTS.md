# S03-CONTRACTS.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_xml

### SIMPLE_XML Contracts

```eiffel
parse (a_xml: READABLE_STRING_GENERAL): SIMPLE_XML_DOCUMENT
  require
    xml_not_empty: not a_xml.is_empty
  ensure
    result_attached: Result /= Void

parse_file (a_path: READABLE_STRING_GENERAL): SIMPLE_XML_DOCUMENT
  require
    path_not_empty: not a_path.is_empty
  ensure
    result_attached: Result /= Void

build (a_root_name: READABLE_STRING_GENERAL): SIMPLE_XML_BUILDER
  require
    name_not_empty: not a_root_name.is_empty
  ensure
    result_attached: Result /= Void

new_document (a_root_name: READABLE_STRING_GENERAL): SIMPLE_XML_DOCUMENT
  require
    name_not_empty: not a_root_name.is_empty
  ensure
    result_attached: Result /= Void
    result_valid: Result.is_valid
```

### SIMPLE_XML_DOCUMENT Contracts

```eiffel
make_empty (a_root_name: STRING)
  require
    name_not_empty: not a_root_name.is_empty
  ensure
    is_valid: is_valid
    root_name_set: attached root as r implies r.name.same_string (a_root_name)

text_at (a_path: READABLE_STRING_GENERAL): STRING
  require
    is_valid: is_valid
  ensure
    result_attached: Result /= Void

element_at (a_path: READABLE_STRING_GENERAL): detachable SIMPLE_XML_ELEMENT
  require
    is_valid: is_valid

to_string: STRING
  require
    is_valid: is_valid
  ensure
    result_attached: Result /= Void
```

### SIMPLE_XML_ELEMENT Contracts

```eiffel
make_from_xm_element (a_element: XM_ELEMENT)
  ensure
    element_set: xm_element = a_element

name: STRING
  ensure
    result_attached: Result /= Void

text: STRING
  ensure
    result_attached: Result /= Void

set_text (a_text: READABLE_STRING_GENERAL): like Current
  ensure
    text_set: text.same_string (a_text.to_string_8)
    fluent: Result = Current
    children_unchanged: child_names_model |=| old child_names_model

add_element (a_name: READABLE_STRING_GENERAL): SIMPLE_XML_ELEMENT
  require
    name_not_empty: not a_name.is_empty
  ensure
    element_added: has_element (a_name)
    count_increased: child_element_count = old child_element_count + 1
```

### SIMPLE_XML_BUILDER Contracts

```eiffel
make (a_root_name: STRING)
  require
    name_not_empty: not a_root_name.is_empty
  ensure
    document_created: xm_document /= Void
    at_root: current_element = xm_document.root_element

element (a_name: READABLE_STRING_GENERAL): like Current
  require
    name_not_empty: not a_name.is_empty
  ensure
    fluent: Result = Current
    moved_into_element: current_element.name.same_string (a_name.to_string_8)
    depth_increased: nesting_depth = old nesting_depth + 1

done: like Current
  require
    not_at_root: not is_at_root
  ensure
    fluent: Result = Current
    depth_decreased: nesting_depth = old nesting_depth - 1

to_document: SIMPLE_XML_DOCUMENT
  ensure
    result_attached: Result /= Void
    result_valid: Result.is_valid
```

### Class Invariants

```eiffel
SIMPLE_XML_DOCUMENT:
  valid_implies_root: is_valid implies root_element /= Void
  invalid_implies_error: not is_valid implies not error_message.is_empty

SIMPLE_XML_ELEMENT:
  element_attached: xm_element /= Void
  name_not_empty: not name.is_empty

SIMPLE_XML_BUILDER:
  document_attached: xm_document /= Void
  current_attached: current_element /= Void
  stack_attached: element_stack /= Void
```
