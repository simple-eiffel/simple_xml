# MML Integration - simple_xml

## Overview
Applied X03 Contract Assault with simple_mml on 2025-01-21.

## MML Classes Used
- `MML_MAP [STRING, STRING]` - Models XML attributes (key-value)
- `MML_SEQUENCE [STRING]` - Models child element names in order

## Model Queries Added
- `attribute_model: MML_MAP [STRING, STRING]` - All attributes
- `child_names_model: MML_SEQUENCE [STRING]` - Child element names
- `child_element_count: INTEGER` - Child count
- `nesting_depth: INTEGER` - Builder nesting level

## Model-Based Postconditions
| Feature | Postcondition | Purpose |
|---------|---------------|---------|
| `attr` | `consistent_with_model`, `value_matches_model` | Attribute access |
| `has_attr` | `consistent_with_model` | Attribute check |
| `set_text` | `children_unchanged` | Text doesn't affect children |
| `set_attr` | `in_domain` | Attr added to model |
| `remove_attr` | `not_in_domain` | Attr removed from model |
| `add_element` | `count_increased`, `name_added_to_model` | Child added |
| `element` (builder) | `depth_increased` | Nesting tracked |
| `done` (builder) | `depth_decreased` | Unnesting tracked |

## Invariants Added
- `name_not_empty` - Element names never empty

## Bugs Found
None (19 redundant preconditions removed)

## Test Results
- Compilation: SUCCESS
- Tests: 18/18 PASS
