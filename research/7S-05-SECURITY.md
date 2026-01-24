# 7S-05-SECURITY.md

**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Library: simple_xml

### Security Considerations

#### XML Entity Attacks
1. **XXE (XML External Entity)**
   - Gobo parser does not resolve external entities by default
   - No file:// or http:// entity expansion
   - MITIGATED

2. **Billion Laughs (Entity Expansion)**
   - Gobo limits entity expansion depth
   - MITIGATED

3. **XML Bomb (Deeply Nested)**
   - Parser has depth limits
   - MITIGATED

#### Input Validation
1. **Malformed XML**
   - Parser returns error state
   - `is_valid` check before processing
   - `error_message` for diagnostics

2. **Encoding Issues**
   - UTF-8 BOM detection
   - Invalid sequences handled

#### Output Escaping
1. **XSS Prevention**
   - `escape_xml` function for all output
   - All special characters properly escaped
   - Via SIMPLE_ZSTRING_ESCAPER

#### File Operations
1. **Path Validation**
   - Check file exists before reading
   - Handle permission errors
   - No path traversal issues

### Not Addressed
- DTD validation (not supported)
- XML Schema validation (not supported)
- Digital signatures
