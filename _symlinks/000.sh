# Check MySQL error log
docker logs alina_mysql 2>&1 | grep -i error

# Test query performance
docker exec alina_mysql mysql -e "SHOW VARIABLES LIKE 'tmpdir';"
docker exec alina_mysql mysql -e "SHOW VARIABLES LIKE 'innodb_temp_data_file_path';"