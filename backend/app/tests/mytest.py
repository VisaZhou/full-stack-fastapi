#自动修复代码命令：ruff check app/tests/mytest.py --fix
import secrets

SECRET_KEY: str = secrets.token_urlsafe(32)
print(SECRET_KEY)
