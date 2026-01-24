# S02-CLASS-CATALOG.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_xml

### Class Hierarchy

```
ANY
  SIMPLE_XML              -- Main facade
  SIMPLE_XML_DOCUMENT     -- Parsed document wrapper
  SIMPLE_XML_ELEMENT      -- Element wrapper
  SIMPLE_XML_BUILDER      -- Fluent document builder
  SIMPLE_XML_SERIALIZER   -- Object-to-XML serializer
  SIMPLE_XML_QUICK        -- Quick operations facade
```

### Class Descriptions

| Class | Responsibility | Key Collaborators |
|-------|----------------|-------------------|
| SIMPLE_XML | High-level parsing/building API | SIMPLE_XML_DOCUMENT, SIMPLE_XML_BUILDER |
| SIMPLE_XML_DOCUMENT | Wrap parsed XML, navigation, serialization | SIMPLE_XML_ELEMENT, XM_DOCUMENT |
| SIMPLE_XML_ELEMENT | Wrap XML element, attributes, children | XM_ELEMENT |
| SIMPLE_XML_BUILDER | Fluent document construction | XM_DOCUMENT, XM_ELEMENT |
| SIMPLE_XML_SERIALIZER | Convert Eiffel objects to XML | SIMPLE_XML_BUILDER, SIMPLE_REFLECTED_OBJECT |
| SIMPLE_XML_QUICK | One-liner XML operations | SIMPLE_XML |

### Creation Procedures

| Class | Creators |
|-------|----------|
| SIMPLE_XML | make |
| SIMPLE_XML_DOCUMENT | default_create, make_from_string, make_from_xm_document, make_empty, make_with_error |
| SIMPLE_XML_ELEMENT | make_from_xm_element |
| SIMPLE_XML_BUILDER | make |
| SIMPLE_XML_SERIALIZER | make |
| SIMPLE_XML_QUICK | make |

### Gobo Wrappers

| Wrapper | Gobo Class |
|---------|------------|
| SIMPLE_XML_DOCUMENT | XM_DOCUMENT |
| SIMPLE_XML_ELEMENT | XM_ELEMENT |
