#!/bin/bash

PATH_SETUP_EXE="$(readlink -f "$0")"
DIR_SETUP_EXE="$(dirname "${PATH_SETUP_EXE}")"
source "${DIR_SETUP_EXE}/inc.sh"

REPORT_FILE="/tmp/mysql_import_diagnostic_$(date +%Y%m%d_%H%M%S).txt"

exec > >(tee -a "$REPORT_FILE")
exec 2>&1

echo "=========================================="
echo "MySQL Import Diagnostic Report"
echo "Started at: $(date)"
echo "=========================================="
echo ""

# 1. System Info
echo "=== SYSTEM INFORMATION ==="
echo "Host: $(hostname)"
echo "Date: $(date)"
echo "Dump file: ${ALINA_LOCAL_DB_DUMPS}/db_m45a.sql"
echo "Dump size: $(ls -lh ${ALINA_LOCAL_DB_DUMPS}/db_m45a.sql | awk '{print $5}')"
echo ""

# 2. Docker Info
echo "=== DOCKER INFORMATION ==="
docker info | grep -E "Storage Driver|Root Dir|Operating System|Total Memory"
echo ""
docker stats --no-stream alina_mysql
echo ""

# 3. Container Disk Speed
echo "=== CONTAINER DISK SPEED TEST ==="
docker exec alina_mysql dd if=/dev/zero of=/tmp/test bs=1M count=100 conv=fdatasync 2>&1 | grep -E "copied|bytes"
docker exec alina_mysql rm -f /tmp/test
echo ""

# 4. MySQL Current Settings
echo "=== MYSQL CURRENT SETTINGS ==="
docker exec alina_mysql mysql -u root -pborg_root_pass -e "
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
SHOW VARIABLES LIKE 'innodb_log_file_size';
SHOW VARIABLES LIKE 'innodb_flush_log_at_trx_commit';
SHOW VARIABLES LIKE 'sync_binlog';
SHOW VARIABLES LIKE 'max_allowed_packet';
SHOW VARIABLES LIKE 'innodb_io_capacity';
" 2>/dev/null
echo ""

# 5. Check for running imports
echo "=== RUNNING PROCESSES ==="
docker exec alina_mysql mysql -u root -pborg_root_pass -e "SHOW PROCESSLIST;" 2>/dev/null | grep -v "Sleep"
echo ""

# 6. Test import with optimizations (5 second test)
echo "=== TESTING IMPORT PERFORMANCE (30 second sample) ==="
echo "Running import for 30 seconds to measure speed..."
echo ""

START_TIME=$(date +%s)
START_BYTES=$(docker exec alina_mysql mysql -u root -pborg_root_pass -e "SELECT SUM(data_length+index_length) FROM information_schema.tables WHERE table_schema='m45a';" 2>/dev/null | tail -1)

timeout 30 docker exec alina_mysql mysql \
  -u "${ALINA_LOCAL_DB_USER}" \
  -p"${ALINA_LOCAL_DB_PASS}" \
  --batch \
  --quick \
  --max_allowed_packet=3G \
  --net_buffer_length=1M \
  --init-command="SET SESSION innodb_flush_log_at_trx_commit=0; SET SESSION sync_binlog=0;" \
  -e "SET FOREIGN_KEY_CHECKS=0; SET UNIQUE_CHECKS=0; SET AUTOCOMMIT=0;" \
  -e "SOURCE ${ALINA_LOCAL_DB_DUMPS}/db_m45a.sql;" \
  -e "COMMIT; SET FOREIGN_KEY_CHECKS=1; SET UNIQUE_CHECKS=1;" 2>/dev/null &

IMPORT_PID=$!
sleep 30
kill $IMPORT_PID 2>/dev/null

END_TIME=$(date +%s)
END_BYTES=$(docker exec alina_mysql mysql -u root -pborg_root_pass -e "SELECT SUM(data_length+index_length) FROM information_schema.tables WHERE table_schema='m45a';" 2>/dev/null | tail -1)

ELAPSED=$((END_TIME - START_TIME))
if [ -n "$START_BYTES" ] && [ -n "$END_BYTES" ]; then
    BYTES_IMPORTED=$((END_BYTES - START_BYTES))
    MB_IMPORTED=$((BYTES_IMPORTED / 1048576))
    MBPS=$((MB_IMPORTED / ELAPSED))
    echo "Imported ~${MB_IMPORTED} MB in ${ELAPSED} seconds = ~${MBPS} MB/sec"
fi
echo ""

# 7. Check MySQL slow log
echo "=== SLOW QUERY STATUS ==="
docker exec alina_mysql mysql -u root -pborg_root_pass -e "SHOW VARIABLES LIKE 'slow_query_log';" 2>/dev/null
echo ""

# 8. System resources
echo "=== SYSTEM RESOURCES ==="
echo "CPU Info:"
docker exec alina_mysql nproc 2>/dev/null || echo "nproc not available"
echo ""
echo "Memory Info:"
docker exec alina_mysql free -h 2>/dev/null || echo "free not available"
echo ""

# 9. Docker container limits
echo "=== CONTAINER RESOURCE LIMITS ==="
docker inspect alina_mysql | grep -E "\"Memory\"|\"CpuShares\"|\"CpuQuota\"|\"CpusetCpus\"" | head -10
echo ""

# 10. Optimized import command
echo "=========================================="
echo "OPTIMIZED IMPORT COMMAND"
echo "=========================================="
echo "Run this command for fastest import:"
echo ""
cat << 'EOF'
docker exec alina_mysql mysql \
  -u "${ALINA_LOCAL_DB_USER}" \
  -p"${ALINA_LOCAL_DB_PASS}" \
  --batch \
  --quick \
  --max_allowed_packet=3G \
  --net_buffer_length=1M \
  --init-command="SET SESSION innodb_flush_log_at_trx_commit=0; SET SESSION sync_binlog=0;" \
  -e "SET FOREIGN_KEY_CHECKS=0; SET UNIQUE_CHECKS=0; SET AUTOCOMMIT=0;" \
  -e "SOURCE ${ALINA_LOCAL_DB_DUMPS}/db_m45a.sql;" \
  -e "COMMIT; SET FOREIGN_KEY_CHECKS=1; SET UNIQUE_CHECKS=1;"
EOF
echo ""
echo "=========================================="
echo "PERMANENT OPTIMIZATIONS (add to my.cnf)"
echo "=========================================="
cat << 'EOF'
[mysqld]
innodb_buffer_pool_size = 2G
innodb_log_file_size = 512M
innodb_flush_log_at_trx_commit = 0
sync_binlog = 0
innodb_flush_method = O_DIRECT
innodb_io_capacity = 2000
EOF
echo ""
echo "=========================================="
echo "Report saved to: $REPORT_FILE"
echo "Finished at: $(date)"
echo "=========================================="