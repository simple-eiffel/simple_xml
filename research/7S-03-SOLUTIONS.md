# 7S-03-SOLUTIONS.md

**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Library: simple_xml

### Alternative Solutions Evaluated

| Solution | Pros | Cons |
|----------|------|------|
| Gobo XML (raw) | Full-featured, mature | Complex API, verbose |
| expat (C) | Fast, lightweight | FFI complexity |
| libxml2 (C) | Full XPath, validation | Heavy, FFI needed |
| Custom parser | Full control | Reinventing wheel |

### Why simple_xml Wrapper
1. **Simplified API** - Hide Gobo complexity
2. **Fluent building** - Method chaining for construction
3. **Path queries** - Simple `root/child/element` navigation
4. **DBC integration** - Contracts throughout
5. **Ecosystem fit** - Consistent with simple_* patterns

### Architecture Decision
- Wrap Gobo XML parser (proven, complete)
- Provide simple_* facade layer
- Add fluent builder pattern
- Include quick one-liner class

### Trade-offs Accepted
- No full XPath (simple paths only)
- No schema validation
- Limited namespace handling
- Depends on Gobo library
