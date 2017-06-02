#!/usr/bin/env python
import string, random, crypt, getpass

if __name__ == "__main__":
    salt_chars = './' + string.ascii_letters + string.digits
    salt = ''.join(random.choice(salt_chars) for _ in range(2))

    password = getpass.getpass("Password for new user:")
    if getpass.getpass("Confirm password:") != password:
        raise ValueError("Passwords don't match")

    print crypt.crypt(password, salt)
