=========================================
ZoneMinder Docker Diagnostic Tool
=========================================

1. Checking coacntainer status...
[0;32m✓ ZoneMinder container is running[0m
[0;32m✓ MySQL container is running[0m

2. Shared Memory (shm) size and usage...
Filesystem      Size  Used Avail Use% Mounted on
shm             2.0G   35M  2.0G   2% /dev/shm

3. Capture processes (zmc) status...
[0;32m✓ Found 2 zmc process(es):[0m
www-data      73 42.2  2.2 832584 372848 ?       Sl   11:45   1:26 /usr/bin/zmc -m 1
www-data      80 30.1  0.8 685124 146028 ?       Sl   11:45   1:01 /usr/bin/zmc -m 2

4. Checking zmc stability (restarts in last 5 minutes)...
[0;32m✓ No recent zmc restarts detected[0m

5. Database connectivity test...
[0;32m✓ Database connection successful[0m

6. Checking ZM_PATH_ZMS configuration...
[0;31m✗ Could not retrieve ZM_PATH_ZMS[0m

7. Checking zms binary...
[0;32m✓ zms binary exists[0m
-rwxr-xr-x 1 root root 1787664 Jun  8  2021 /usr/lib/zoneminder/cgi-bin/zms
[0;32m✓ nph-zms binary exists[0m

8. Apache CGI module status...
[0;32m✓ CGI module is enabled[0m

9. Socket directory (/run/zm) status...
total 16
drwxr-xr-- 2 www-data www-data 4096 May  9 11:49 .
drwxr-xr-x 1 root     root     4096 May  9 11:43 ..
-rw-rw-r-- 1 www-data www-data    2 May  9 11:45 zm.pid
srwxrwxr-x 1 www-data www-data    0 May  9 11:45 zmdc.sock
-rw------- 1 www-data www-data    0 May  9 11:45 zms-403205.lock
-rw------- 1 www-data www-data    0 May  9 11:45 zms-463916.lock
-rw------- 1 www-data www-data    0 May  9 11:47 zms-532461.lock
-rw------- 1 www-data www-data    0 May  9 11:46 zms-758089.lock
-rw------- 1 www-data www-data    0 May  9 11:46 zms-774068.lock
-rw------- 1 www-data www-data    0 May  9 11:46 zms-871408.lock
-rw------- 1 www-data www-data    0 May  9 11:47 zms-975792.lock
srwxr-xr-x 1 www-data www-data    0 May  9 11:47 zms-975792s.sock
[1;33m⚠ No socket files found (normal if no streams are being viewed)[0m

10. Recent errors from logs (last 20 lines)...
--- zmdc.log ---

--- zmc_m1.log ---

11. Checking docker-compose.yml key settings...
shm_size:
links:
  NOT configured (may cause DNS issues)
ZM_PATH_ZMS env:
  NOT configured

12. Testing container-to-container network...
[0;31m✗ Cannot ping mysql container[0m

=========================================
Diagnostic complete!
=========================================
