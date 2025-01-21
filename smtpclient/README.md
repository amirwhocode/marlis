## MTA
Configuring SSMTP as the Mail Transfer Agent (MTA) for ILIAS
To enable ILIAS to send email notifications and messages through an external SMTP server, you need to configure SSMTP as the system's Mail Transfer Agent (MTA).

### Configuration File Location
On Linux, the main configuration file for SSMTP can be found at:

```
/etc/ssmtp/ssmtp.conf
```

In this file, you'll specify the SMTP server details, authentication (if required), and other settings that allow ILIAS to send emails.

