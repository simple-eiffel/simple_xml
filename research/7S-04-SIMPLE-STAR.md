# 7S-04-SIMPLE-STAR.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_xml

### Dependencies on simple_* Ecosystem

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_zstring | XML escaping | SIMPLE_ZSTRING_ESCAPER |
| simple_encoding | BOM detection | SIMPLE_ENCODING_DETECTOR |
| simple_reflection | Object serialization | SIMPLE_REFLECTED_OBJECT |

### Ecosystem Patterns Followed

1. **Facade Pattern** - SIMPLE_XML provides simplified API
2. **Quick Class** - SIMPLE_XML_QUICK for one-liners
3. **Builder Pattern** - SIMPLE_XML_BUILDER for fluent construction
4. **Error Handling** - `is_valid` / `error_message` pattern

### Class Naming Convention
- `SIMPLE_XML` - Main facade
- `SIMPLE_XML_DOCUMENT` - Parsed document
- `SIMPLE_XML_ELEMENT` - Element wrapper
- `SIMPLE_XML_BUILDER` - Fluent builder
- `SIMPLE_XML_QUICK` - Quick operations
- `SIMPLE_XML_SERIALIZER` - Object-to-XML

### Consistent API Design
```eiffel
-- Parse
doc := xml.parse (source)

-- Query
value := doc.text_at ("root/child")

-- Build
doc := xml.build ("root")
         .element ("child").text ("value").done
       .to_document
```
