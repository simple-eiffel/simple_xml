# S06-BOUNDARIES.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_xml

### API Boundaries

#### Public API (SIMPLE_XML)
- `make` - Constructor
- `parse` - Parse string
- `parse_file` - Parse file
- `query` - Query elements
- `build` - Start builder
- `new_document` - Empty document

#### Document API (SIMPLE_XML_DOCUMENT)
- Navigation: `text_at`, `attr_at`, `element_at`, `elements_at`
- Status: `is_valid`, `has_error`, `error_message`
- Serialization: `to_string`, `to_pretty_string`, `save_to_file`

#### Element API (SIMPLE_XML_ELEMENT)
- Access: `name`, `text`, `inner_xml`
- Attributes: `attr`, `has_attr`, `attributes`
- Children: `element`, `elements`, `all_elements`
- Modification: `set_text`, `set_attr`, `add_element`

#### Builder API (SIMPLE_XML_BUILDER)
- Building: `element`, `attr`, `text`, `comment`, `done`
- Conversion: `to_document`, `to_string`, `to_pretty_string`

#### Quick API (SIMPLE_XML_QUICK)
- One-liners: `xpath`, `first`, `attr`, `count`, `exists`
- Building: `element`
- Validation: `is_valid`

### Export Policies

```eiffel
SIMPLE_XML_ELEMENT:
  feature {SIMPLE_XML_ELEMENT, SIMPLE_XML_DOCUMENT, SIMPLE_XML_BUILDER}
    xm_element  -- Internal access only

SIMPLE_XML_BUILDER:
  feature {NONE}
    xm_document
    current_element
    element_stack
```

### Integration Points

| External System | Integration Method |
|-----------------|-------------------|
| Gobo XML | XM_* class wrapping |
| simple_zstring | Escaping functions |
| simple_encoding | BOM detection |
| simple_reflection | Object serialization |
| File System | PLAIN_TEXT_FILE |

### Error Propagation
```
Gobo Parser Error -> XM_TREE_CALLBACKS_PIPE.error
                  -> SIMPLE_XML_DOCUMENT.error_message
                  -> is_valid = False
```
