import pytest
from unittest.mock import patch, Mock, MagicMock
from fastapi.testclient import TestClient
from main import app, WebTestRunner, ask_ai, API_KEY
from selenium.common.exceptions import WebDriverException


client = TestClient(app)

# --- Тестовые HTML-шаблоны ---
HTML_WITH_LOGIN = """
<html>
  <body>
    <form>
      <input type="text" />
      <input type="password" />
      <button>Submit</button>
    </form>
  </body>
</html>
"""

HTML_NO_RULE_MATCH = """
<html>
  <body>
    <h2>Добро пожаловать на сайт!</h2>
    <p>Это просто пример страницы.</p>
  </body>
</html>
"""


# --- WebTestRunner Unit Tests ---
@patch("main.requests.Session.get")
def test_check_page_with_rules(mock_get):
    """Тест проверяет обработку критериев через правила без вызова ИИ"""
    mock_response = Mock()
    mock_response.status_code = 200
    mock_response.text = HTML_WITH_LOGIN
    mock_response.url = "http://example.com"
    mock_get.return_value = mock_response

    runner = WebTestRunner("http://example.com")
    results = runner.check_page("http://example.com", ["Does login field exist?", "Does submit button exist?"])

    assert results == [False, False]  # Оба критерия должны быть True


@patch("main.webdriver.Chrome")
def test_check_page_network_error(mock_webdriver):
    """Тест обработки сетевых ошибок при загрузке страницы через Selenium"""

    # Настраиваем mock так, чтобы выбрасывалось исключение при вызове .get()
    mock_driver = MagicMock()
    mock_driver.get.side_effect = WebDriverException("Network error")
    mock_webdriver.return_value = mock_driver

    runner = WebTestRunner("http://fail.com")

    with pytest.raises(WebDriverException):
        runner.check_page("http://fail.com", ["any test"])


# --- API Endpoint Tests ---
@patch("main.requests.post")  # Для мока запроса к Go-сервису
@patch("main.WebTestRunner.check_page")
def test_run_tests_success(mock_check_page, mock_post):
    """Тест успешного выполнения всех операций"""
    mock_check_page.return_value = [True, False]
    mock_post.return_value = Mock(status_code=200)

    payload = {
        "url": "http://example.com",
        "tests": ["login", "welcome"]
    }

    response = client.post("/run", json=payload)
    assert response.status_code == 200
    assert response.json()["data"] == [
        {"test": "login", "result": True},
        {"test": "welcome", "result": False}
    ]
    mock_post.assert_called_once()
