# Method 1: Direct binary call
/usr/bin/php7.4 /path/to/legacy-script.php
/usr/bin/php8.5 /path/to/modern-script.php

# Method 2: Using aliases (after sourcing the aliases file)
php74 /path/to/legacy-script.php
php85 /path/to/modern-script.php

# Method 3: Shebang line in your PHP script
#!/usr/bin/php7.4
<?php
// Your legacy code here