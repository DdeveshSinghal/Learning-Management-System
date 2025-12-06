#!/usr/bin/env python3
import requests
import time
import sys

BASE = 'http://127.0.0.1:8000'
TIMEOUT = 60

def main():
    start = time.time()
    while time.time() - start < TIMEOUT:
        try:
            r = requests.get(BASE + '/api/')
            if r.status_code < 500:
                print('backend up')
                return 0
        except Exception:
            pass
        time.sleep(1)
    print('backend not up', file=sys.stderr)
    return 1


if __name__ == '__main__':
    sys.exit(main())
