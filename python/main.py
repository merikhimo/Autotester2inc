import sys
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin
import json
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Any, Optional, Dict
from huggingface_hub import InferenceClient
from openai import OpenAI
import os
import language_tool_python

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

# --- Data models (reverted to original format) ---
class APIResponse(BaseModel):
    data: Optional[Any] = None

class InputData(BaseModel):
    url: str
    tests: List[str]

app = FastAPI()

# --- Commented out: additional test generation ---
# def generate_additional_tests(page_type: str, existing: List[str]) -> List[str]:
#     prompt = (
#         f"Для страницы типа '{page_type}' предложи дополнительные критерии проверки сайта. "
#         f"Уже есть: {existing}. Верни JSON-массив строк без пояснений."
#     )
#     response = ask_ai(prompt)
#     try:
#         suggestions = json.loads(response)
#         if isinstance(suggestions, list):
#             return [s for s in suggestions if s not in existing]
#     except Exception:
#         pass
#     return []

class WebTestRunner:
    def __init__(self, start_url: str):
        self.session = requests.Session()
        self.current_url = start_url
        self.current_html = ""
        self.spell_tool = language_tool_python.LanguageTool('ru')

    def fetch_page(self, url: str) -> str:
        resp = self.session.get(url)
        resp.raise_for_status()
        self.current_url = resp.url
        self.current_html = resp.text
        return resp.text

    def check_with_rules(self, soup: BeautifulSoup, criterion: str) -> Optional[bool]:
        c = criterion.lower()
        if "login" in c:
            return bool(soup.find("input", {"type": "password"}))
        if "submit" in c or "button" in c or "клик" in c:
            el = soup.find(lambda tag: (tag.name == 'a' and tag.has_attr('href')) or tag.has_attr('onclick') or tag.name=='button')
            return bool(el)
        if "header" in c and "welcome" in c:
            return bool(soup.find(lambda tag: tag.name in ["h1", "h2"] and "welcome" in tag.get_text().lower()))
        return None

    def check_spelling(self, soup: BeautifulSoup) -> Dict[str, Any]:
        text = soup.get_text(separator=' ', strip=True)
        matches = self.spell_tool.check(text)
        errors = []
        for m in matches[:5]:
            errors.append({
                'text': text[m.offset:m.offset+m.errorLength],
                'suggestions': m.replacements
            })
        return {
            'ok': len(matches) == 0,
            'count': len(matches),
            'examples': errors
        }

    def narrow_relevant_html(self, soup: BeautifulSoup) -> BeautifulSoup:
        candidates = soup.find_all(['main', 'div'], recursive=True)
        if not candidates:
            return soup
        return max(candidates, key=lambda tag: len(tag.get_text(strip=True)))

    def check_page(self, url: str, tests: List[str]) -> List[Any]:
        resp = self.session.get(url)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, 'lxml')
        results: List[Any] = []
        # Проверяем каждый критерий
        for criterion in tests:
            result = self.check_with_rules(soup, criterion)
            if result is None:
                excerpt = self.narrow_relevant_html(soup).get_text(" ", strip=True)[:1000]
                question = f"Yes or No: {criterion}? Context: {excerpt}"
                answer = ask_ai(question).lower()
                result = answer.startswith("yes")
            results.append({"test": criterion, "result": result})
        # Орфография
        spell_report = self.check_spelling(soup)
        results.append({"test": "spelling_check", "result": spell_report['ok'], "details": spell_report})
        return results

@app.post("/run", response_model=APIResponse)
def run_tests(data: InputData):
    runner = WebTestRunner(data.url)
    try:
        # Генерировать дополнительные тесты закомментировано, используем только переданные data.tests
        results = runner.check_page(data.url, data.tests)
    except Exception as e:
        return APIResponse(status="error")

    try:
        post_resp = requests.post(
            "http://go-api:8081/api/results",
            json=results,
            timeout=5
        )
        post_resp.raise_for_status()
    except Exception as e:
        return APIResponse(status="error", error=f"Failed to send results: {e}")

    return APIResponse(
        data=results
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=3000)
