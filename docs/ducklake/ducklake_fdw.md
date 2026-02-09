# DuckLake Foreign Data Wrapper

The DuckLake Foreign Data Wrapper (FDW) provides read-only access to DuckLake tables from PostgreSQL.

**Modes:**
- `dbname` mode (default): access DuckLake catalogs that use this PostgreSQL instance as metadata service.
- `uri` mode: access a DuckLake catalog by URI/path (for example frozen DuckLakes).

## Quick Start

```sql
-- 1. Create the foreign server
CREATE SERVER ducklake_server
    FOREIGN DATA WRAPPER ducklake_fdw;

-- 2. Create a foreign table (column list must be empty)
CREATE FOREIGN TABLE my_foreign_table ()
    SERVER ducklake_server
    OPTIONS (schema_name 'public', table_name 'my_ducklake_table');

-- 3. Query the foreign table
SELECT * FROM my_foreign_table WHERE id > 100;
```

## Server Options

```sql
CREATE SERVER ducklake_server
    FOREIGN DATA WRAPPER ducklake_fdw
    OPTIONS (
        dbname 'my_database',      -- Optional: defaults to current database
        uri 'ducklake:https://example.com/my.ducklake', -- Optional: DuckLake URI/path
        metadata_schema 'ducklake' -- Optional: defaults to 'ducklake' in dbname mode
    );
```

| Option | Required | Default | Description |
| :--- | :--- | :--- | :--- |
| `dbname` | No | Current DB | The PostgreSQL database containing the DuckLake tables |
| `uri` | No | None | DuckLake URI/path to attach (e.g. `ducklake:https://...`) |
| `metadata_schema` | No | `ducklake` in `dbname` mode | The schema where DuckLake metadata tables reside |

`dbname` and `uri` are mutually exclusive. If both are provided, server creation fails.

User mapping is unnecessary and not allowed. In `dbname` mode, the FDW accesses DuckLake tables through the local PostgreSQL instance using the current session's credentials to preserve PostgreSQL permission checks.

## Frozen DuckLakes

Example server definition for a frozen DuckLake catalog:

```sql
CREATE SERVER frozen_ducklake_server
    FOREIGN DATA WRAPPER ducklake_fdw
    OPTIONS (
        uri 'ducklake:https://my-bucket/path/to/frozen_catalog.ducklake'
    );
```

## Foreign Table Options

```sql
CREATE FOREIGN TABLE my_ducklake_table ()
    SERVER ducklake_server
    OPTIONS (
        schema_name 'public',  -- Required: schema name in DuckLake
        table_name 'users'     -- Required: table name in DuckLake
    );
```

| Option | Required | Description |
| :--- | :--- | :--- |
| `schema_name` | Yes | The schema name of the table in DuckLake |
| `table_name` | Yes | The table name in DuckLake |

**Important:** Column definitions are automatically inferred from DuckLake metadata. You must specify an empty column list `()`. Specifying columns manually will result in an error:

```sql
-- This will fail
CREATE FOREIGN TABLE my_table (id INT, name TEXT)
    SERVER ducklake_server
    OPTIONS (schema_name 'public', table_name 'users');
-- ERROR: cannot specify column definitions for DuckLake foreign table
```

## Cross-Database Queries

Query DuckLake tables from other databases on the same PostgreSQL instance:

```sql
-- From database 'analytics', query tables in 'warehouse' database
CREATE SERVER warehouse_server
    FOREIGN DATA WRAPPER ducklake_fdw
    OPTIONS (dbname 'warehouse');

CREATE FOREIGN TABLE warehouse_sales ()
    SERVER warehouse_server
    OPTIONS (schema_name 'public', table_name 'sales');

SELECT * FROM warehouse_sales WHERE region = 'West';
```

## Schema Changes

If the underlying DuckLake table schema changes (columns added or removed), recreate the foreign table to pick up the new schema:

```sql
DROP FOREIGN TABLE my_foreign_table;
CREATE FOREIGN TABLE my_foreign_table ()
    SERVER ducklake_server
    OPTIONS (schema_name 'public', table_name 'my_ducklake_table');
```

## Troubleshooting

### Table Not Found

```
ERROR: Cannot create foreign table: DuckLake table "public.my_table" in database "mydb" is not accessible.
```

Verify that:
1. The `schema_name` and `table_name` options are correct
2. The `metadata_schema` option points to the correct schema (default: `ducklake` in `dbname` mode)
3. You have permission to access the table

Check if the table exists:

```sql
\c target_database
SELECT t.table_name, s.schema_name
FROM ducklake.ducklake_table t
JOIN ducklake.ducklake_schema s USING (schema_id)
WHERE s.schema_name = 'public'
  AND t.table_name = 'my_table'
  AND t.end_snapshot IS NULL;
```

### Permission Errors

Ensure your PostgreSQL user has:
- `USAGE` privilege on the foreign server
- Access to the target database specified in the `dbname` option
- Read permissions on the DuckLake metadata schema
