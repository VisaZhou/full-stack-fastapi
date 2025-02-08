# 检查并自动修复可修复的代码问题，如导入顺序、空格等：ruff check app/tests/mytest.py --fix
# 进行代码格式化，它会调整代码样式使其符合统一的格式标准：ruff format app/tests/mytest.py
from fastapi.testclient import TestClient

from app.tests.utils.utils import get_superuser_token_headers


def test_superuser_token_headers(client: TestClient) -> dict[str, str]:
    headers = get_superuser_token_headers(client)
    assert "Authorization" in headers
    assert headers["Authorization"].startswith("Bearer ")
