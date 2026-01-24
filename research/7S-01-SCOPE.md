# 7S-01-SCOPE.md

**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Library: simple_xml

### Problem Domain
XML parsing, building, and manipulation for Eiffel applications with a simple, fluent API.

### Core Use Cases
1. Parse XML strings and files into document trees
2. Navigate XML structures with path-based queries
3. Build XML documents programmatically with fluent API
4. Modify existing XML documents
5. Serialize XML to strings and files
6. Serialize Eiffel objects to XML

### Target Users
- Eiffel developers working with XML data
- Applications consuming XML APIs
- Configuration file processing
- Data interchange scenarios

### Boundaries
- **In Scope**: XML parsing, building, navigation, serialization, object-to-XML
- **Out of Scope**: Full XPath, XSLT, XML Schema validation, DTD validation, namespaces (limited)

### Success Criteria
- Parse valid XML documents
- Build XML with fluent chaining API
- Navigate with simple path expressions
- Serialize with pretty printing
- Escape/unescape special characters correctly
