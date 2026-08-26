divert(-1)dnl
divert(0)dnl
define(`_USE_ETC_MAIL_')dnl
include(`/usr/share/sendmail/cf/m4/cf.m4')dnl
VERSIONID(`$Id: sendmail.mc, v 8.15.2-18 2020-03-08 00:39:49 cowboy Exp $')
OSTYPE(`debian')dnl
DOMAIN(`debian-mta')dnl
undefine(`confHOST_STATUS_DIRECTORY')dnl
FEATURE(`no_default_msa')dnl
DAEMON_OPTIONS(`Family=inet,  Name=MTA-v4, Port=smtp, Addr=127.0.0.1')dnl
DAEMON_OPTIONS(`Family=inet,  Name=MSP-v4, Port=submission, M=Ea, Addr=127.0.0.1')dnl
define(`confPRIVACY_FLAGS',`needmailhelo,needexpnhelo,needvrfyhelo,restrictqrun,restrictexpand,nobodyreturn,authwarnings')dnl
define(`confCONNECTION_RATE_THROTTLE', `15')dnl
define(`confCONNECTION_RATE_WINDOW_SIZE',`10m')dnl
FEATURE(`use_cw_file')dnl
FEATURE(`access_db', , `skip')dnl
FEATURE(`greet_pause', `1000')dnl
FEATURE(`delay_checks', `friend', `n')dnl
define(`confBAD_RCPT_THROTTLE',`3')dnl
FEATURE(`conncontrol', `nodelay', `terminate')dnl
FEATURE(`ratecontrol', `nodelay', `terminate')dnl
include(`/etc/mail/m4/dialup.m4')dnl
include(`/etc/mail/m4/provider.m4')dnl
define(`SMART_HOST',`smtp.gmail.com:587')dnl
define(`RELAY_MAILER_ARGS', `TCP $h 587')dnl
define(`confAUTH_OPTIONS', `A p')dnl
define(`confDOMAIN_NAME', `ospl1942.ru')dnl
define(`confMAILER_NAME', `Fail2Ban')dnl
define(`confFROM_HEADER', `ospl-1942 <root@ospl1942.ru>')dnl
TRUST_AUTH_MECH(`LOGIN PLAIN')dnl
define(`confAUTH_MECHANISMS', `LOGIN PLAIN')dnl
FEATURE(`authinfo',`hash /etc/mail/authinfo.db')dnl
define(`confCACERT_PATH', `/etc/ssl/certs')dnl
define(`confCACERT', `/etc/ssl/certs/ca-certificates.crt')dnl
define(`confDEF_USER_ID', `8:12')dnl
MAILER_DEFINITIONS
MAILER(`local')dnl
MAILER(`smtp')dnl
