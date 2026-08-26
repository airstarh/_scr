Here are all the packages that were installed during the mail setup:

```bash
# Sendmail and dependencies
sudo apt install sendmail -y
sudo apt install sendmail-cf -y
sudo apt install m4 -y

# SASL authentication support
sudo apt install sasl2-bin -y

# CA certificates for TLS
sudo apt install ca-certificates -y

# Mail utilities (optional, for testing)
sudo apt install mailutils -y
sudo apt install bsd-mailx -y
```

## Complete one-liner for all packages:

```bash
sudo apt install sendmail sendmail-cf m4 sasl2-bin ca-certificates mailutils bsd-mailx -y
```

## Summary of what each package does:

| Package | Purpose |
|---------|---------|
| `sendmail` | Main MTA (Mail Transfer Agent) |
| `sendmail-cf` | Configuration files for sendmail |
| `m4` | Macro processor needed to build sendmail config |
| `sasl2-bin` | Authentication support for SMTP |
| `ca-certificates` | SSL/TLS certificates for secure connection |
| `mailutils` | Mail commands (mail, mailx) for testing |
| `bsd-mailx` | Additional mail command utilities |

## To verify all are installed:

```bash
dpkg -l | grep -E "sendmail|sasl2|ca-certificates|mailutils|bsd-mailx|m4"
```
