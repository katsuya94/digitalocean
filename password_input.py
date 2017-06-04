#!/usr/bin/env python
import getpass, sys

password = getpass.getpass(sys.argv[1])
if password != getpass.getpass('confirm ' + sys.argv[1]):
    raise

print password
