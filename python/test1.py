import threading
import http.server
import socketserver
import socket
import json
import time
import requests
import sys

# ------- 1. Патчим DNS для хоста go-api -------
_real_getaddrinfo = socket.getaddrinfo
def _patched_getaddrinfo(host, *args, **kwargs):
    if host == "go-api":
        host = "127.0.0.1"
    return _real_getaddrinfo(host, *args, **kwargs)

socket.getaddrinfo = _patched_getaddrinfo

# ------- 2. Тестовый HTTP-сервер для /api/results -------
PORT = 8081
class StubHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path == "/api/results":
            length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(length).decode('utf-8')
            try:
                data = json.loads(body)
            except json.JSONDecodeError:
                data = body
            print(f"[Stub /api/results] received:\n{json.dumps(data, ensure_ascii=False, indent=2)}\n")
            # всегда OK
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"status":"ok"}')
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        # отключаем стандартный лог
        return

def start_stub_server():
    with socketserver.TCPServer(("", PORT), StubHandler) as httpd:
        print(f"[Stub server] Listening on port {PORT} (for go-api)...")
        httpd.serve_forever()

# ------- 3. Функция для тестов -------
BASE_URL = "http://localhost:3000"

def test_run(url: str, page_type: str, tests: list):
    payload = {
        "url": url,
        "page_type": page_type,
        "tests": tests
    }
    print(f"\n>>> Sending /run with payload:\n{json.dumps(payload, ensure_ascii=False, indent=2)}")
    try:
        resp = requests.post(f"{BASE_URL}/run", json=payload)
        resp.raise_for_status()
    except requests.RequestException as e:
        print(f"[ERROR] /run failed: {e}")
        return
    print(f"[Response {resp.status_code}]:")
    try:
        print(json.dumps(resp.json(), ensure_ascii=False, indent=2))
    except Exception:
        print(resp.text)

if __name__ == "__main__":
    # 1) Стартуем stub-сервер
    server_thread = threading.Thread(target=start_stub_server, daemon=True)
    server_thread.start()

    # 2) Ждём, чтобы сервер успел подняться
    time.sleep(1)

    # 3) Два примера
    test_run(
        url="https://arsenal-tools.net",
        page_type="Главная страница",
        tests=[
            "Есть ли логин",
            "Есть ли кнопка \"Отправить\"",
            "Присутствует ли заголовок \"Welcome\""
        ]
    )

    test_run(
        url="https://arsenal-tools.net/catalog",
        page_type="Каталог",
        tests=[
            "Есть ли фильтр по цене",
            "Есть ли кликабельный элемент товара",
        ]
    )

    # 4) Дадим немного времени на получение запросов в stub, потом выходим
    time.sleep(2)
    print("Done.")
