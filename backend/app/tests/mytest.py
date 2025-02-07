import secrets
SECRET_KEY: str = secrets.token_urlsafe(32)
print(SECRET_KEY)