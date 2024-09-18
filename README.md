# chirpd

A simple docker service for JUST sending emails, using postfix

## Getting Started

1. Generate DKIM keys:
   ```sh
   ./scripts/gen-dkim
   ```

2. Start stack('nt):
   ```sh
   docker-compose up -d
   ```

3. Add a mail address:
   ```sh
   python3 manage.py add --email user@example.com --password "your_password"
   ```

## Test

To send a test email, use the following command:

```sh
python3 manage.py test --email user@example.com --password "your_password" --recipient recipient@example.com
```
