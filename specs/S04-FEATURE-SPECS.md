# S04-FEATURE-SPECS.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_xml

### SIMPLE_XML Features

| Feature | Signature | Description |
|---------|-----------|-------------|
| make | | Create XML processor |
| parse | (xml: READABLE_STRING_GENERAL): SIMPLE_XML_DOCUMENT | Parse XML string |
| parse_file | (path: READABLE_STRING_GENERAL): SIMPLE_XML_DOCUMENT | Parse XML file |
| query | (doc: SIMPLE_XML_DOCUMENT; path: READABLE_STRING_GENERAL): ARRAYED_LIST[SIMPLE_XML_ELEMENT] | Query elements |
| build | (root_name: READABLE_STRING_GENERAL): SIMPLE_XML_BUILDER | Start building |
| new_document | (root_name: READABLE_STRING_GENERAL): SIMPLE_XML_DOCUMENT | Create empty doc |

### SIMPLE_XML_DOCUMENT Features

| Feature | Signature | Description |
|---------|-----------|-------------|
| is_valid | : BOOLEAN | Parse success? |
| has_error | : BOOLEAN | Parse failed? |
| error_message | : STRING | Error description |
| root | : detachable SIMPLE_XML_ELEMENT | Root element |
| text_at | (path: READABLE_STRING_GENERAL): STRING | Get text at path |
| attr_at | (path, attr: READABLE_STRING_GENERAL): detachable STRING | Get attribute |
| element_at | (path: READABLE_STRING_GENERAL): detachable SIMPLE_XML_ELEMENT | Get element |
| elements_at | (path: READABLE_STRING_GENERAL): ARRAYED_LIST[SIMPLE_XML_ELEMENT] | Get all matches |
| to_string | : STRING | Compact XML |
| to_pretty_string | : STRING | Indented XML |
| save_to_file | (path: READABLE_STRING_GENERAL) | Write to file |

### SIMPLE_XML_ELEMENT Features

| Feature | Signature | Description |
|---------|-----------|-------------|
| name | : STRING | Tag name |
| text | : STRING | Text content |
| inner_xml | : STRING | All content as XML |
| attr | (name: READABLE_STRING_GENERAL): detachable STRING | Get attribute |
| has_attr | (name: READABLE_STRING_GENERAL): BOOLEAN | Has attribute? |
| attributes | : HASH_TABLE[STRING, STRING] | All attributes |
| element | (name: READABLE_STRING_GENERAL): detachable SIMPLE_XML_ELEMENT | First child by name |
| elements | (name: READABLE_STRING_GENERAL): ARRAYED_LIST[SIMPLE_XML_ELEMENT] | All children by name |
| all_elements | : ARRAYED_LIST[SIMPLE_XML_ELEMENT] | All children |
| has_element | (name: READABLE_STRING_GENERAL): BOOLEAN | Has child? |
| parent | : detachable SIMPLE_XML_ELEMENT | Parent element |
| set_text | (text: READABLE_STRING_GENERAL): like Current | Set text (fluent) |
| set_attr | (name, value: READABLE_STRING_GENERAL): like Current | Set attribute (fluent) |
| remove_attr | (name: READABLE_STRING_GENERAL): like Current | Remove attribute (fluent) |
| add_element | (name: READABLE_STRING_GENERAL): SIMPLE_XML_ELEMENT | Add child |

### SIMPLE_XML_BUILDER Features

| Feature | Signature | Description |
|---------|-----------|-------------|
| make | (root_name: STRING) | Create with root |
| element | (name: READABLE_STRING_GENERAL): like Current | Add and enter child |
| attr | (name, value: READABLE_STRING_GENERAL): like Current | Add attribute |
| text | (text: READABLE_STRING_GENERAL): like Current | Set text |
| done | : like Current | Return to parent |
| comment | (text: READABLE_STRING_GENERAL): like Current | Add comment |
| is_at_root | : BOOLEAN | At root level? |
| nesting_depth | : INTEGER | Current depth |
| to_document | : SIMPLE_XML_DOCUMENT | Build document |
| to_string | : STRING | Build and serialize |
| to_pretty_string | : STRING | Build and pretty-print |

### SIMPLE_XML_QUICK Features

| Feature | Signature | Description |
|---------|-----------|-------------|
| parse | (xml: STRING): detachable SIMPLE_XML_DOCUMENT | Parse string |
| parse_file | (path: STRING): detachable SIMPLE_XML_DOCUMENT | Parse file |
| xpath | (xml, query: STRING): ARRAYED_LIST[STRING] | Query text content |
| first | (xml, query: STRING): detachable STRING | First match text |
| attr | (xml, query, attr_name: STRING): detachable STRING | Get attribute |
| count | (xml, query: STRING): INTEGER | Count matches |
| exists | (xml, query: STRING): BOOLEAN | Any matches? |
| element | (name, content: STRING): STRING | Build simple element |
| is_valid | (xml: STRING): BOOLEAN | Valid XML? |
| last_error | : STRING | Error message |
