# S05-CONSTRAINTS.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_xml

### Technical Constraints

1. **XML Version**
   - XML 1.0 supported
   - XML 1.1 not tested

2. **Encoding**
   - UTF-8 default
   - UTF-8 BOM detection
   - Other encodings via Gobo

3. **Path Queries**
   - Simple paths: `root/child/element`
   - No XPath expressions
   - No predicates `[1]`, `[@attr='value']`
   - No wildcards `*`

4. **Namespaces**
   - Default namespace only
   - No prefix handling
   - No namespace queries

5. **Document Types**
   - DTD not validated
   - Schema not validated
   - DOCTYPE preserved but not processed

### Dependency Constraints

1. **Gobo XML Required**
   - Part of standard EiffelStudio
   - XM_EIFFEL_PARSER
   - XM_DOCUMENT tree model

2. **simple_zstring Required**
   - For XML escaping
   - SIMPLE_ZSTRING_ESCAPER

3. **EiffelStudio Version**
   - Requires EiffelStudio 22.05 or later
   - Void-safe mode required

### Performance Constraints

1. **Memory**
   - Full DOM tree in memory
   - No SAX-style streaming
   - Large documents may be slow

2. **Thread Safety**
   - Not thread-safe
   - One document per thread
   - No SCOOP annotations yet
