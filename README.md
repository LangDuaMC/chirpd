# chirpd

A simple docker service for JUST sending emails, using postfix

## Getting Started
0. Write your `.env`
   ```sh
   DOMAIN=kys.org
   MAIL_HOST=very_cool_namespace.kys.org
   ```

2. Generate DKIM keys:
   ```sh
   ./scripts/gen-dkim
   ```

   in `data` directory should have DKIM DNS value in txt ( pls take exactly in `( ... )`. you can keep quotes but some dns service may deny endline )
   you should also have [SPF and DMARC value](https://www.cloudflare.com/learning/email-security/dmarc-dkim-spf/) to avoid being spam flagged.

3. Start stack('nt):
   ```sh
   docker-compose up -d --build
   ```

5. Add a mail address:
   ```sh
   python3 manage.py add --email user@example.com --password "your_password"
   ```

## Test

To send a test email, use the following command:

```sh
python3 manage.py test --email user@example.com --password "your_password" --recipient recipient@example.com
```

Using [mail-tester.com](https://www.mail-tester.com/) to test the final result
