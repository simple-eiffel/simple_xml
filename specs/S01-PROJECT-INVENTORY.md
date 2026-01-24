# S01-PROJECT-INVENTORY.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_xml

### Source Files

| File | Path | Purpose |
|------|------|---------|
| simple_xml.e | src/ | Main facade class |
| simple_xml_document.e | src/ | Parsed document wrapper |
| simple_xml_element.e | src/ | Element wrapper |
| simple_xml_builder.e | src/ | Fluent document builder |
| simple_xml_serializer.e | src/ | Object-to-XML serializer |
| simple_xml_quick.e | src/ | Quick one-liner operations |

### Test Files

| File | Path | Purpose |
|------|------|---------|
| test_app.e | testing/ | Test application entry |
| lib_tests.e | testing/ | Test suite |

### Configuration Files

| File | Purpose |
|------|---------|
| simple_xml.ecf | Library ECF |
| simple_xml_tests.ecf | Test target ECF |

### Dependencies
- Gobo XML (XM_* classes)
- simple_zstring (SIMPLE_ZSTRING_ESCAPER)
- simple_encoding (SIMPLE_ENCODING_DETECTOR)
- simple_reflection (SIMPLE_REFLECTED_OBJECT)
- EiffelBase

### Directory Structure
```
simple_xml/
  src/
    simple_xml.e
    simple_xml_document.e
    simple_xml_element.e
    simple_xml_builder.e
    simple_xml_serializer.e
    simple_xml_quick.e
  testing/
    test_app.e
    lib_tests.e
  research/
  specs/
```
