# S07-SPEC-SUMMARY.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_xml

### Executive Summary
simple_xml provides a simplified, fluent API for XML parsing, building, and manipulation in Eiffel. It wraps the Gobo XML library to hide complexity while providing DBC contracts and ecosystem integration.

### Key Capabilities
1. **Parse XML** - From strings or files to document tree
2. **Navigate** - Simple path-based queries
3. **Build** - Fluent method chaining for construction
4. **Modify** - Change attributes, text, add elements
5. **Serialize** - To compact or pretty-printed strings
6. **Object-to-XML** - Reflection-based serialization

### Architecture
```
SIMPLE_XML (Facade)
    |
    +-- SIMPLE_XML_DOCUMENT
    |       +-- SIMPLE_XML_ELEMENT[]
    |               (wraps XM_ELEMENT)
    |
    +-- SIMPLE_XML_BUILDER
    |       (builds XM_DOCUMENT)
    |
    +-- SIMPLE_XML_SERIALIZER
    |       (uses SIMPLE_REFLECTED_OBJECT)
    |
    +-- SIMPLE_XML_QUICK (One-liners)
```

### Class Count
- Total: 6 classes
- Facade: 1 (SIMPLE_XML)
- Document: 2 (DOCUMENT, ELEMENT)
- Builder: 1 (BUILDER)
- Utilities: 2 (SERIALIZER, QUICK)

### Contract Coverage
- All public features have preconditions
- Fluent methods return Current
- Model queries for contract specification
- Error state via `is_valid` / `error_message`

### Ecosystem Integration
- Depends on: Gobo XML, simple_zstring, simple_encoding, simple_reflection
- Used by: simple_xlsx
- Consistent simple_* API patterns
