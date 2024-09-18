import crypt
import smtplib
import os
import argparse
from email.message import EmailMessage

USERS_FILE = 'users'

def hash_password(password, use_sha512=True):
    if use_sha512:
        return '{SHA512-CRYPT}' + crypt.crypt(password, crypt.mksalt(crypt.METHOD_SHA512))
    else:
        return '{PLAIN}' + password

def add_user(email, password, use_sha512=True):
    hashed_password = hash_password(password, use_sha512)
    with open(USERS_FILE, 'a') as f:
        f.write(f"{email}:{hashed_password}\n")
    print(f"User {email} added successfully.")

def remove_user(email):
    with open(USERS_FILE, 'r') as f:
        lines = f.readlines()
    with open(USERS_FILE, 'w') as f:
        for line in lines:
            if not line.startswith(email + ':'):
                f.write(line)
    print(f"User {email} removed successfully.")

def list_users():
    with open(USERS_FILE, 'r') as f:
        for line in f:
            print(line.split(':')[0])

def send_test_email(sender, recipient, password):
    msg = EmailMessage()
    msg.set_content("This is a test email from chirpd.")
    msg['Subject'] = "Test Email from chirpd"
    msg['From'] = sender
    msg['To'] = recipient

    try:
        with smtplib.SMTP('localhost', 25) as s:
            s.login(sender, password)
            s.send_message(msg)
        print(f"Test email sent successfully to {recipient}")
    except Exception as e:
        print(f"Error sending email: {e}")

def main():
    parser = argparse.ArgumentParser(description="Manage chirpd users and send test emails")
    parser.add_argument('action', choices=['add', 'remove', 'list', 'test'], help="Action to perform")
    parser.add_argument('--email', help="User's email address")
    parser.add_argument('--password', help="User's password")
    parser.add_argument('--recipient', help="Recipient's email address for test email")
    parser.add_argument('--plain', action='store_true', help="Store password as plain text")

    args = parser.parse_args()

    if args.action == 'add':
        if not args.email or not args.password:
            print("Email and password are required for adding a user.")
            return
        add_user(args.email, args.password, not args.plain)
    elif args.action == 'remove':
        if not args.email:
            print("Email is required for removing a user.")
            return
        remove_user(args.email)
    elif args.action == 'list':
        list_users()
    elif args.action == 'test':
        if not args.email or not args.password or not args.recipient:
            print("Email, password, and recipient are required for sending a test email.")
            return
        send_test_email(args.email, args.recipient, args.password)

if __name__ == "__main__":
    main()
