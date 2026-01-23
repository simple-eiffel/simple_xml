# D01: Structure Analysis - simple_xml + simple_encoding Integration

## Date: 2026-01-20

## Summary

- Classes: 5 source files
- Current dependencies: simple_zstring (already integrated)
- Proposed addition: simple_encoding

## Current File Handling

SIMPLE_XML.parse_file (lines 52-73):
- Reads file directly as STRING_8
- No BOM detection or encoding handling

## Integration Opportunity

Add BOM detection/stripping for XML file parsing:
- Strip UTF-8 BOM if present before parsing
- Consistent with simple_json BOM handling

## Changes Required

### ECF
```xml
<library name="simple_encoding" location="$SIMPLE_EIFFEL/simple_encoding/simple_encoding.ecf"/>
```

### SIMPLE_XML
Add `strip_utf8_bom` helper (same pattern as simple_json)

## Decision

Proceed with minimal integration for BOM handling consistency.
