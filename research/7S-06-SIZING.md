# 7S-06-SIZING.md

**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Library: simple_xml

### Code Metrics

| Class | Lines | Features | Complexity |
|-------|-------|----------|------------|
| SIMPLE_XML | ~150 | 8 | Low (facade) |
| SIMPLE_XML_DOCUMENT | ~340 | 18 | Medium |
| SIMPLE_XML_ELEMENT | ~420 | 28 | Medium |
| SIMPLE_XML_BUILDER | ~185 | 12 | Low |
| SIMPLE_XML_SERIALIZER | ~180 | 8 | Medium |
| SIMPLE_XML_QUICK | ~235 | 18 | Low |

### Total Estimated
- **Lines of Code**: ~1,510
- **Classes**: 6
- **Features**: ~92

### Memory Characteristics
- Document tree: O(elements + attributes + text)
- Builder stack: O(nesting depth)
- String interning: Via Gobo

### Performance Targets
- Parse 1MB XML: < 500ms
- Build 1000 elements: < 100ms
- Serialize: Similar to parse time

### Gobo Dependency
- XM_EIFFEL_PARSER
- XM_TREE_CALLBACKS_PIPE
- XM_DOCUMENT, XM_ELEMENT
- XM_FORMATTER
- XM_INDENT_PRETTY_PRINT_FILTER
