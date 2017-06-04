#!/usr/bin/env python
import getpass, os, sys

fd = os.open('/dev/tty', os.O_RDWR|os.O_NOCTTY)
tty = os.fdopen(fd, 'w+', 1)
print getpass._raw_input(sys.argv[1], stream=tty, input=tty)
