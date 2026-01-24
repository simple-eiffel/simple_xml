# 7S-02-STANDARDS.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_xml

### Applicable Standards

1. **XML 1.0** - W3C Recommendation
   - Well-formed XML documents
   - Element and attribute syntax
   - Entity references

2. **XML Namespaces** - W3C Recommendation
   - Basic namespace support via Gobo

### Character Encoding
- UTF-8 as default encoding
- BOM detection and stripping
- XML declaration processing

### Entity References

| Entity | Character |
|--------|-----------|
| `&lt;` | < |
| `&gt;` | > |
| `&amp;` | & |
| `&quot;` | " |
| `&apos;` | ' |

### Well-Formedness Requirements
- Single root element
- Properly nested elements
- Matching start/end tags
- Attribute values quoted
- No duplicate attributes

### Underlying Implementation
- Gobo XML library (XM_EIFFEL_PARSER)
- XM_TREE_CALLBACKS_PIPE for tree building
- XM_FORMATTER for serialization
