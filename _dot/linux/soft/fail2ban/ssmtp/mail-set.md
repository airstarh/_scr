**Yes!** It's much easier than sendmail. Here's how to switch:

## 1. Install ssmtp

```bash
sudo apt install ssmtp mailutils -y
```

## 2. Configure ssmtp

```bas
sudo nano /etc/ssmtp/ssmtp.conf
```

Replace everything with:

```
mailhub=smtp.gmail.com:587
AuthUser=vsevolod.azovsky@gmail.com
AuthPass=kjnuwjknvbkocaso
UseSTARTTLS=YES
FromLineOverride=YES
maildomain=ospl1942.ru
hostname=ospl1942.ru
```

## 3. Configure revaliases

```bash
sudo nano /etc/ssmtp/revaliases
```

Add:

```
root:Fail2Ban Alert <vsevolod.azovsky@gmail.com>:smtp.gmail.com:587
sewa:Fail2Ban Alert <vsevolod.azovsky@gmail.com>:smtp.gmail.com:587
```

## 4. Update Fail2Ban

```bash
sudo nano /etc/fail2ban/jail.local
```

Change in `[DEFAULT]`:

```ini
mta = mail
sender = Fail2Ban Alert <vsevolod.azovsky@gmail.com>
destemail = vsevolod.azovsky@gmail.com
```

## 5. Stop sendmail

```bash
sudo systemctl stop sendmail
sudo systemctl disable sendmail
```

## 6. Test

```bash
echo "Test from ssmtp" | mail -s "Test" vsevolod.azovsky@gmail.com
```

## 7. Restart Fail2Ban

```bash
sudo systemctl restart fail2ban
```

## 8. Test Fail2Ban

```bash
sudo fail2ban-client set sshd banip 1.2.3.4
```

Check your inbox - emails should arrive with **"Fail2Ban Alert"** as the sender!

## If you want to keep sendmail but just want ssmtp:

You can keep both - just make sure `mta = mail` points to ssmtp in jail.local.

The key difference: **ssmtp is 100x simpler** and the From field will work properly without fighting Gmail! 🎉
