sudo systemctl restart fail2ban

printf "To: vsevolod.azovsky+test@gmail.com\nFrom: \"OSPL\" <root@ospl1942.ru>\nSubject: Test\n\nTest message\n.\n" | /usr/sbin/sendmail -t -v


echo -e "From: \"Fail2Ban Alert\" <root@ospl1942.ru>\nTo: vsevolod.azovsky@gmail.com\nSubject: Test\n\nTest message" | /usr/sbin/sendmail -t -v


echo -e "From: \"Fail2Ban Alert\" <root@ospl1942.ru>\nTo: vsevolod.azovsky+test3@gmail.com\nSubject: Test\n\nTest message" | /usr/sbin/sendmail -t -v
