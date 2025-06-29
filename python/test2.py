import pytest
from unittest.mock import patch, Mock
from fastapi.testclient import TestClient
from main import WebTestRunner, app, API_KEY

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
def test_check_page_with_login(mock_get):
    mock_response = Mock()
    mock_response.status_code = 200
    mock_response.text = HTML_WITH_LOGIN
    mock_get.return_value = mock_response

    runner = WebTestRunner("http://example.com")
    results = runner.check_page("http://example.com", ["login", "submit"])

    assert any(r['result'] is True for r in results if r['test'] == "login")
    assert any(r['result'] is True for r in results if r['test'] == "submit")
    assert any(r['test'] == "spelling_check" for r in results)


@patch("main.requests.Session.get")
@patch("main.ask_ai")
def test_check_page_ai_fallback(mock_ask_ai, mock_get):
    mock_response = Mock()
    mock_response.status_code = 200
    mock_response.text = HTML_NO_RULE_MATCH
    mock_get.return_value = mock_response

    mock_ask_ai.return_value = "Yes, this is true."

    runner = WebTestRunner("http://example.com")
    results = runner.check_page("http://example.com", ["Is it a welcome page?"])

    assert any(r['result'] is True for r in results if r['test'] == "Is it a welcome page?")
    mock_ask_ai.assert_called_once()


@patch("main.requests.Session.get")
def test_check_page_network_error(mock_get):
    mock_get.side_effect = Exception("Network error")
    runner = WebTestRunner("http://fail.com")

    with pytest.raises(Exception):
        runner.check_page("http://fail.com", ["any test"])

# --- API Endpoint Tests ---

@patch("main.requests.post")
@patch("main.WebTestRunner.check_page")
@patch("main.generate_additional_tests", return_value=["extra test"])
def test_run_tests_success(mock_gen, mock_check_page, mock_post):
    mock_check_page.return_value = [
        {"test": "login", "result": True},
        {"test": "extra test", "result": False}
    ]
    mock_post.return_value = Mock(status_code=200)

    payload = {
        "url": "http://example.com",
        "page_type": "login_page",
        "tests": ["login"]
    }

    response = client.post("/run", json=payload)
    assert response.status_code == 200
    assert response.json()["status"] == "success"
    assert "results" in response.json()["data"]


@patch("main.requests.post")
@patch("main.WebTestRunner.check_page", side_effect=Exception("bad HTML"))
def test_run_tests_check_page_failure(mock_check, mock_post):
    payload = {
        "url": "http://example.com",
        "page_type": "any",
        "tests": ["test"]
    }

    response = client.post("/run", json=payload)
    assert response.status_code == 200
    assert response.json()["status"] == "error"
    assert "bad HTML" in response.json()["error"]


@patch("main.requests.post", side_effect=Exception("POST fail"))
@patch("main.WebTestRunner.check_page", return_value=[{"test": "x", "result": True}])
@patch("main.generate_additional_tests", return_value=[])
def test_run_tests_result_post_failure(mock_gen, mock_check, mock_post):
    payload = {
        "url": "http://example.com",
        "page_type": "type",
        "tests": ["check something"]
    }

    response = client.post("/run", json=payload)
    assert response.status_code == 200
    assert response.json()["status"] == "error"
    assert "Failed to send results" in response.json()["error"]
