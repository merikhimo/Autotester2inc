import requests
from bs4 import BeautifulSoup
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Any, Optional
from openai import OpenAI
import os
import logging


# --- API client setup ---
API_KEY = os.getenv("OPENAI_API_KEY", "sk-0M12tbkrnKubF86nHyKPKidkqoqfNzei")
BASE_URL = "https://api.proxyapi.ru/openai/v1"

client = OpenAI(
    api_key=API_KEY,
    base_url=BASE_URL
)

def ask_ai(prompt: str) -> str:
    chat_completion = client.chat.completions.create(
        model="gpt-4.1-2025-04-14",
        messages=[{"role": "user", "content": prompt}]
    )
    return chat_completion.choices[0].message.content.strip()

class APIResponse(BaseModel):
    data: Optional[Any] = None


class InputData(BaseModel):
    url: str
    tests: List[str]


app = FastAPI()


class WebTestRunner:
    def __init__(self, start_url: str):
        self.session = requests.Session()
        self.current_url = start_url
        self.current_html = ""

    def fetch_page(self, url: str) -> str:
        resp = self.session.get(url, params={"user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36"})
        resp.raise_for_status()
        self.current_url = resp.url
        self.current_html = resp.text
        return resp.text

    def check_with_rules(self, soup: BeautifulSoup, criterion: str) -> Optional[bool]:
        c = criterion.lower()
        if "login" in c:
            return bool(soup.find("input", {"type": "password"}))
        if "submit" in c or "button" in c:
            return bool(soup.find("button") or soup.find("input", {"type": "submit"}))
        if "header" in c and "welcome" in c:
            return bool(soup.find(lambda tag: tag.name in ["h1", "h2"] and "welcome" in tag.get_text().lower()))
        return None

    def narrow_relevant_html(self, soup: BeautifulSoup) -> BeautifulSoup:
        candidates = soup.find_all(['main', 'div'], recursive=True)
        if not candidates:
            return soup
        return max(candidates, key=lambda tag: len(tag.get_text(strip=True)))

    def check_page(self, url: str, prompts: List[str]) -> List[bool]:
        resp = self.session.get(url)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, 'lxml')
        results: List[bool] = []
        for criterion in prompts:
            result = self.check_with_rules(soup, criterion)
            if result is None:
                excerpt = self.narrow_relevant_html(soup).get_text(" ", strip=True)[:1000]
                question = f"Yes or No: {criterion}? Context: {excerpt}"
                answer = ask_ai(question).lower()
                logging.log(level=logging.INFO, msg=answer)
                result = answer.startswith("yes") or 'yes' in answer
            results.append(result)
        return results


@app.post("/run", response_model=APIResponse)
def run_tests(data: InputData):
    runner = WebTestRunner(data.url)
    try:
        results = runner.check_page(data.url, data.tests)
    except Exception as e:
        return APIResponse(status="error", error=str(e))

    # Формируем данные в формате, который ожидает Go-сервер
    go_payload = [
        {"test": test, "result": result}
        for test, result in zip(data.tests, results)
    ]

    try:
        # Отправляем данные в Go-сервис
        post_resp = requests.post(
            "http://go-api:8081/api/results",
            json=go_payload,  # Отправляем массив объектов напрямую
            timeout=5
        )
        post_resp.raise_for_status()
    except Exception as e:
        return APIResponse(status="error", error=f"Failed to send results: {e}")


    print(go_payload)
    # Возвращаем ответ в формате FastAPI
    return APIResponse(
        data=go_payload,
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=3000)

    # print(ask_ai("Как у тебя дела?"))
