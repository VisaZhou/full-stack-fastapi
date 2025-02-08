# 检查并自动修复可修复的代码问题，如导入顺序、空格等：ruff check app/tests/mytest.py --fix
# 进行代码格式化，它会调整代码样式使其符合统一的格式标准：ruff format app/tests/mytest.py


def test_superuser_token_headers(superuser_token_headers: dict[str, str]) -> None:
    headers = superuser_token_headers
    assert "Authorization" in headers
    assert headers["Authorization"].startswith("Bearer ")
