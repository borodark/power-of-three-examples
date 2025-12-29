# Power-of-Three Documentation Cleanup Plan

**Date:** 2025-12-26
**Goal:** Remove PostgreSQL proxy leftovers, primary key heresy, and cache over-focus

## Files to Clean

### High Priority - Active Documentation

1. **README.md** ✅ Clean
   - No PostgreSQL proxy references
   - No primary key heresy
   - Minimal cache mentions

2. **CUBE_MODELS_LOCATION.md** ✅ Already updated
   - Points to Arrow Native location
   - Notes Python tests use port 4444 (factual, not promotional)

3. **ADBC_SETUP.md** ✅ Clean
   - About actual PostgreSQL database (port 15432), not CubeSQL proxy
   - No issues

### Medium Priority - Python Package

4. **python/adbc_driver_cube/README.md** ⚠️ Needs cleanup
   - References to port 4444
   - May have primary key mentions

5. **python/adbc_driver_cube/__init__.py** ⚠️ Check
   - Default port 4444 for PostgreSQL mode
   - Should clarify Arrow Native is preferred

6. **python/test_arrow_cache_performance.py** ⚠️ Check
   - Uses port 4444 (PostgreSQL protocol)
   - Should note it's for PostgreSQL wire protocol testing only

7. **integration_test.py** ⚠️ Check
   - Uses port 4444
   - Should clarify scope

### Low Priority - Archived Documentation

8. **doc/archive/development/SEGFAULT_ROOT_CAUSE_AND_RESOLUTION.md** ❌ Primary key heresy
   - States primary keys are required (FALSE)
   - Should be updated or marked as obsolete

9. **doc/archive/development/INVESTIGATION_SUMMARY.md** ❌ Primary key heresy
   - States primary keys are required (FALSE)
   - Should be updated or marked as obsolete

10. **doc/archive/arrow-ipc/*.md** ⏭️ Skip
    - Archived historical documents
    - Can be left as-is for historical reference

## Cleanup Actions

### Action 1: Mark Archived Docs as Obsolete

Add disclaimer to archived primary key documents:

```markdown
> **⚠️ OBSOLETE INFORMATION**
>
> This document contains outdated information about primary keys being required.
> Primary keys are OPTIONAL in Cube - use MEASURE syntax with GROUP BY instead.
>
> See `/home/io/projects/learn_erl/cube/examples/recipes/arrow-ipc/POWER_OF_THREE_QUERY_EXAMPLES.md`
> for correct query patterns.
```

### Action 2: Update Python Package Documentation

**python/adbc_driver_cube/README.md:**
- Add note that Arrow Native (port 4445) is recommended
- Clarify PostgreSQL wire protocol (port 4444) is for legacy compatibility

### Action 3: Update Python Test Scripts

Add comments clarifying scope:
```python
"""
NOTE: This test uses PostgreSQL wire protocol (port 4444) for legacy compatibility testing.
For production use, Arrow Native protocol (port 4445) is recommended.
See POWER_OF_THREE_QUERY_EXAMPLES.md for Arrow Native examples.
"""
```

## Files That Are Correct (No Changes Needed)

- ✅ CUBE_MODELS_LOCATION.md - Already points to Arrow Native
- ✅ ADBC_SETUP.md - About real PostgreSQL, not CubeSQL proxy
- ✅ README.md - Clean and factual

## Summary

**Total Files:** ~10-12 files need attention
**Priority:**
1. Mark archived primary key docs as obsolete (2 files)
2. Update Python package README (1 file)
3. Add clarifying comments to Python tests (2 files)

**Archive Strategy:** Leave historical docs but add disclaimers
**Python Strategy:** Note PostgreSQL protocol is for compatibility, Arrow Native preferred
