# OpenTenBase Advanced Test Suite

This directory contains advanced test modules for OpenTenBase distributed database.

## Modules

| Module | Description |
|--------|-------------|
| `test_transactions.sh` | Distributed transaction commit/rollback, cross-node consistency, isolation levels, savepoints |
| `test_connection_pool.sh` | Connection pool configuration, max connections, connection reuse, timeout handling |
| `test_data_types.sh` | Basic types, datetime, JSON/JSONB, arrays, large objects |
| `test_performance.sh` | Bulk INSERT, SELECT, JOIN performance, index effectiveness |
| `test_failover.sh` | GTM/Datanode/Coordinator failover recovery, data consistency |

## Prerequisites

- OpenTenBase cluster running with Coordinator on `127.0.0.1:5432`
- `psql` client available in PATH
- Sufficient permissions to create/drop databases and tables

## Usage

Run all tests:

```bash
for script in test/advanced/test_*.sh; do
  echo "=== Running $script ==="
  bash "$script"
done
```

Run a single module:

```bash
bash test/advanced/test_transactions.sh
echo $?  # 0 = pass, 1 = fail
```

## Exit Codes

- `0` -- All tests passed
- `1` -- One or more tests failed

## Logging

Each module uses three log functions:

- `log_pass "message"` -- green PASS output
- `log_fail "message"` -- red FAIL output
- `log_info "message"` -- informational output

## Notes

- Each module is independently runnable.
- Test data is cleaned up after each module completes.
- Ensure the cluster is healthy before running failover tests.
