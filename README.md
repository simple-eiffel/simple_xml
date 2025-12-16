<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/claude_eiffel_op_docs/main/artwork/LOGO.png" alt="simple_ library logo" width="400">
</p>

# simple_xml

**[Documentation](https://simple-eiffel.github.io/simple_xml/)** | **[GitHub](https://github.com/simple-eiffel/simple_xml)**

XML parsing and building library for Eiffel with fluent API. Parse XML documents, navigate elements, modify content, and build XML programmatically.

## Overview

`simple_xml` provides a high-level, world-class API over Eiffel's Gobo XM_* classes:

- **Parsing** - Parse XML from strings or files with error handling
- **Navigation** - Direct path-based access and fluent element navigation
- **Modification** - Set text, attributes, and add elements
- **Building** - Fluent XML document construction
- **Serialization** - Output as compact or pretty-printed XML

## API Integration

`simple_xml` is part of the `simple_*` API hierarchy:

```
FOUNDATION_API (core utilities: json, uuid, base64, validation, xml)
       |
SERVICE_API (services: jwt, smtp, sql, cors, cache, websocket, pdf)
       |
APP_API (full application stack)
```

### Using via FOUNDATION_API or Higher

If your project uses `simple_foundation_api`, `simple_service_api`, or `simple_app_api`, you automatically have access to `simple_xml` - no additional ECF entry needed:

```eiffel
class MY_CONFIG_LOADER

inherit
    FOUNDATION_API  -- or SERVICE_API, APP_API

feature
    load_config (a_path: STRING)
        local
            xml: SIMPLE_XML
            doc: SIMPLE_XML_DOCUMENT
        do
            create xml.make
            doc := xml.parse_file (a_path)
            if doc.is_valid then
                db_host := doc.text_at ("config/database/host")
                db_port := doc.text_at ("config/database/port")
            end
        end
end
```

### Standalone Installation

For projects that only need XML functionality:

1. Clone the repository
2. Set the ecosystem environment variable (one-time setup for all simple_* libraries): `SIMPLE_EIFFEL=D:\prod`
3. Add to your ECF:

```xml
<library name="simple_xml" location="$SIMPLE_EIFFEL/simple_xml/simple_xml.ecf"/>
```

## Dependencies

| Library | Purpose | Environment Variable |
|---------|---------|---------------------|
| Gobo XML (built-in) | XM_* classes | (ISE_LIBRARY) |

## Quick Start (Zero-Configuration)

Use `SIMPLE_XML_QUICK` for the simplest possible XML operations:

```eiffel
local
    xml: SIMPLE_XML_QUICK
    titles: ARRAYED_LIST [STRING]
do
    create xml.make

    -- XPath query - get all matching text content
    titles := xml.xpath (book_xml, "//book/title")

    -- Get first match
    if attached xml.first (book_xml, "//book/title") as title then
        print (title)
    end

    -- Get attribute value
    if attached xml.attr (book_xml, "//book", "id") as id then
        print ("Book ID: " + id)
    end

    -- Simple element access (no XPath)
    if attached xml.text (html, "title") as t then
        print ("Page title: " + t)
    end

    -- Get all element texts
    across xml.texts (html, "p") as p loop
        print (p)  -- all paragraph texts
    end

    -- Count matching nodes
    print ("Books: " + xml.count (library_xml, "//book").out)

    -- Check if exists
    if xml.exists (config_xml, "//database/host") then ...

    -- Build simple elements
    print (xml.element ("name", "Alice"))
    -- <name>Alice</name>

    -- Validation
    if xml.is_valid (some_xml) then ...
end
```

## Standard API (Full Control)

### Parsing XML

```eiffel
local
    xml: SIMPLE_XML
    doc: SIMPLE_XML_DOCUMENT
do
    create xml.make
    doc := xml.parse ("<root><item>value</item></root>")
    if doc.is_valid then
        print (doc.text_at ("root/item"))  -- Outputs: value
    end
end
```

### Building XML

```eiffel
local
    xml: SIMPLE_XML
    doc: SIMPLE_XML_DOCUMENT
do
    create xml.make
    doc := xml.build ("config")
        .element ("database")
            .element ("host").text ("localhost").done
            .element ("port").text ("5432").done
        .done
        .to_document

    print (doc.to_pretty_string)
end
```

## Parsing

### Parse from String

```eiffel
local
    xml: SIMPLE_XML
    doc: SIMPLE_XML_DOCUMENT
do
    create xml.make
    doc := xml.parse ("<root><item id=%"123%">content</item></root>")

    if doc.is_valid then
        -- Use document
    elseif doc.has_error then
        print ("Parse error: " + doc.error_message)
    end
end
```

### Parse from File

```eiffel
local
    xml: SIMPLE_XML
    doc: SIMPLE_XML_DOCUMENT
do
    create xml.make
    doc := xml.parse_file ("config.xml")

    if doc.is_valid then
        -- Process configuration
    end
end
```

## Navigation

### Direct Path Navigation

Access elements and values directly by path:

```eiffel
local
    xml: SIMPLE_XML
    doc: SIMPLE_XML_DOCUMENT
    items: ARRAYED_LIST [SIMPLE_XML_ELEMENT]
do
    create xml.make
    doc := xml.parse (config_xml)

    -- Get text at path
    host := doc.text_at ("config/database/host")

    -- Get attribute at path
    if attached doc.attr_at ("config/database", "port") as port then
        db_port := port.to_integer
    end

    -- Get multiple elements
    items := doc.elements_at ("root/items/item")
    across items as item loop
        print (item.text)
    end
end
```

### Fluent Element Navigation

Chain element access for complex navigation:

```eiffel
local
    xml: SIMPLE_XML
    doc: SIMPLE_XML_DOCUMENT
do
    create xml.make
    doc := xml.parse (xml_string)

    if attached doc.root as root then
        if attached root.element ("items") as items then
            if attached items.element ("item") as item then
                print (item.text)
                print (item.attr ("id"))
            end
        end

        -- Or using element_at for path navigation
        if attached root.element_at ("items/item") as item then
            print (item.text)
        end
    end
end
```

## Element Features

### Accessing Content

```eiffel
if attached doc.root as root then
    -- Element name
    print (root.name)

    -- Text content
    print (root.text)

    -- Get attribute value
    if attached root.attr ("id") as id then
        print (id)
    end

    -- Check if attribute exists
    if root.has_attr ("type") then
        -- ...
    end

    -- Get all attributes
    across root.attributes as attr loop
        print (@attr.key + "=" + attr)
    end

    -- Get all child elements
    across root.all_elements as elem loop
        print (elem.name)
    end

    -- Get inner XML
    print (root.inner_xml)
end
```

### Modification (Fluent)

All modification methods return `Current` for chaining:

```eiffel
if attached doc.root as root then
    if attached root.element ("item") as item then
        -- Chain modifications
        item.set_text ("new value")
            .set_attr ("id", "123")
            .set_attr ("type", "updated")
            .remove_attr ("old_attr")

        -- Add child element
        item.add_element ("child").set_text ("child content")
    end
end
```

## Building XML

### Basic Building

```eiffel
local
    xml: SIMPLE_XML
    doc: SIMPLE_XML_DOCUMENT
do
    create xml.make
    doc := xml.build ("root")
        .element ("item").attr ("id", "1").text ("value").done
        .element ("item").attr ("id", "2").text ("other").done
        .to_document
end
```

### Nested Building

```eiffel
local
    xml: SIMPLE_XML
    doc: SIMPLE_XML_DOCUMENT
do
    create xml.make
    doc := xml.build ("config")
        .element ("database")
            .element ("host").text ("localhost").done
            .element ("port").text ("5432").done
            .element ("name").text ("myapp").done
        .done
        .element ("logging")
            .attr ("level", "info")
            .element ("file").text ("/var/log/app.log").done
        .done
        .to_document
end
```

### Adding Comments

```eiffel
doc := xml.build ("root")
    .comment ("Configuration generated by MyApp")
    .element ("settings")
        .element ("option").text ("value").done
    .done
    .to_document
```

## Serialization

### To String

```eiffel
local
    doc: SIMPLE_XML_DOCUMENT
    compact_xml: STRING
    pretty_xml: STRING
do
    -- Compact (no formatting)
    compact_xml := doc.to_string

    -- Pretty-printed (indented)
    pretty_xml := doc.to_pretty_string
end
```

### Save to File

```eiffel
doc.save_to_file ("output.xml")
```

## Error Handling

```eiffel
local
    xml: SIMPLE_XML
    doc: SIMPLE_XML_DOCUMENT
do
    create xml.make
    doc := xml.parse ("<root><unclosed>")

    if doc.has_error then
        print ("Parse failed: " + doc.error_message)
    end

    -- Safe navigation (returns empty/void on failure)
    if doc.text_at ("nonexistent/path").is_empty then
        print ("Element not found")
    end
end
```

## Architecture

```
SIMPLE_XML (main facade)
    |-- parse (string): SIMPLE_XML_DOCUMENT
    |-- parse_file (path): SIMPLE_XML_DOCUMENT
    |-- build (root_name): SIMPLE_XML_BUILDER
    |-- new_document (root_name): SIMPLE_XML_DOCUMENT

SIMPLE_XML_DOCUMENT (parsed/built document)
    |-- root: SIMPLE_XML_ELEMENT
    |-- text_at, attr_at, element_at, elements_at
    |-- to_string, to_pretty_string, save_to_file

SIMPLE_XML_ELEMENT (element wrapper)
    |-- name, text, attr, attributes
    |-- element, elements, all_elements, element_at
    |-- set_text, set_attr, remove_attr, add_element
    |-- parent, inner_xml

SIMPLE_XML_BUILDER (fluent builder)
    |-- element, attr, text, comment, done
    |-- to_document, to_string, to_pretty_string
```

## API Summary

### SIMPLE_XML (Facade)

| Feature | Description |
|---------|-------------|
| `make` | Create XML processor |
| `parse (xml)` | Parse XML string |
| `parse_file (path)` | Parse XML file |
| `build (root_name)` | Start fluent builder |
| `new_document (root_name)` | Create empty document |

### SIMPLE_XML_DOCUMENT

| Feature | Description |
|---------|-------------|
| `is_valid` | Document parsed successfully |
| `has_error` | Parsing failed |
| `error_message` | Error description |
| `root` | Root element |
| `text_at (path)` | Get text at path |
| `attr_at (path, name)` | Get attribute at path |
| `element_at (path)` | Get element at path |
| `elements_at (path)` | Get all elements at path |
| `to_string` | Compact XML string |
| `to_pretty_string` | Indented XML string |
| `save_to_file (path)` | Save to file |

### SIMPLE_XML_ELEMENT

| Feature | Description |
|---------|-------------|
| `name` | Element tag name |
| `text` | Text content |
| `attr (name)` | Get attribute value |
| `has_attr (name)` | Check attribute exists |
| `attributes` | All attributes |
| `element (name)` | First child by name |
| `elements (name)` | All children by name |
| `all_elements` | All child elements |
| `element_at (path)` | Element at relative path |
| `text_at (path)` | Text at relative path |
| `parent` | Parent element |
| `inner_xml` | Content as XML string |
| `set_text (text)` | Set text (fluent) |
| `set_attr (name, value)` | Set attribute (fluent) |
| `remove_attr (name)` | Remove attribute (fluent) |
| `add_element (name)` | Add child element |

### SIMPLE_XML_BUILDER

| Feature | Description |
|---------|-------------|
| `element (name)` | Add child, move into it |
| `attr (name, value)` | Add attribute |
| `text (content)` | Set text content |
| `comment (text)` | Add XML comment |
| `done` | Return to parent |
| `is_at_root` | Check if at root |
| `to_document` | Build document |
| `to_string` | Build and serialize |
| `to_pretty_string` | Build and format |

## Test Coverage

The library includes comprehensive tests covering:

- **Parsing**: Valid XML, error handling
- **Navigation**: text_at, attr_at, elements_at, fluent navigation
- **Building**: Simple builds, nested structures
- **Modification**: set_text, set_attr, add_element
- **Serialization**: to_string output

Run tests: `EIFGENs/simple_xml_tests/W_code/simple_xml.exe`

## License

MIT License - Copyright (c) 2024-2025, Larry Rix
