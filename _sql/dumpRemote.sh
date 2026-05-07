# Dump each database separately
for db in alina m45a stage vov; do
    mysqldump -u root -p --databases $db --single-transaction --routines --triggers --events --add-drop-database > ${db}_backup.sql
done

# Compress all
gzip *_backup.sql

# Copy all to local
# scp username@remote_server:*_backup.sql.gz .

# On local, restore specific database
# mysql -u root -p < alina_backup.sql