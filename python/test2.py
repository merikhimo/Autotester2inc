import pytest
from unittest.mock import patch, Mock
from main import WebTestRunner

# Фейковый HTML с элементами
HTML_WITH_LOGIN = """
<html>
  <body>
    <form>
      <input type="text" name="username" />
      <input type="password" name="password" />
      <button type="submit">Login</button>
    </form>
  </body>
</html>
"""

# Фейковый HTML без логина
HTML_WITHOUT_LOGIN = "<html><body><h1>Welcome to our site</h1></body></html>"

@patch("main.requests.Session.get")
def test_check_page_with_login(mock_get):
    mock_response = Mock()
    mock_response.status_code = 200
    mock_response.text = HTML_WITH_LOGIN
    mock_get.return_value = mock_response

    runner = WebTestRunner("http://example.com")
    results = runner.check_page("http://example.com", ["login", "submit"])

    assert results == [True, True]

@patch("main.requests.Session.get")
@patch("main.ask_ai")
def test_check_page_ai_fallback(mock_ai, mock_get):
    mock_response = Mock()
    mock_response.status_code = 200
    mock_response.text = HTML_WITHOUT_LOGIN
    mock_get.return_value = mock_response

    # ИИ отвечает "Yes"
    mock_ai.return_value = "Yes, it is accessible."

    runner = WebTestRunner("http://example.com")
    results = runner.check_page("http://example.com", ["Is this a welcome page?"])

    assert results == [True]
    mock_ai.assert_called_once()

@patch("main.requests.Session.get")
def test_check_page_invalid_url(mock_get):
    mock_get.side_effect = Exception("Network error")

    runner = WebTestRunner("http://badurl.com")

    with pytest.raises(Exception):
        runner.check_page("http://badurl.com", ["any test"])
