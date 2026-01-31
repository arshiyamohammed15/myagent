#!/usr/bin/env python3

import jwt
from datetime import datetime, timedelta, timezone

SECRET_KEY = 'test-secret-key'
ALGORITHM = 'HS256'

now = datetime.now(timezone.utc)
payload = {
    'sub': 'api-user',
    'iat': now,
    'exp': now + timedelta(minutes=60),
}

token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
print(token)