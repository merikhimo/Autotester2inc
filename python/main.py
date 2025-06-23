import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin
import json
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Any, Optional

HF_TOKEN = "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"


def ask_ai(prompt: str) -> str:
    from huggingface_hub import InferenceClient

    client = InferenceClient(
        provider="hf-inference",
        token=HF_TOKEN
    )

    response = client.chat_completion(
        model="microsoft/phi-4",
        messages=[{"role": "user", "content": prompt}]
    )
    return response.choices[0].message.content.strip()


class APIResponse(BaseModel):
    status: str
    data: Optional[Any] = None
    error: Optional[str] = None


class InputData(BaseModel):
    link: str
    criterias: List[str]


app = FastAPI()


class WebTestRunner:
    def __init__(self, start_url: str):
        self.session = requests.Session()
        self.current_url = start_url
        self.current_html = ""

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

    def check_page(self, link: str, prompts: List[str]) -> List[bool]:
        resp = self.session.get(link)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, 'lxml')
        results: List[bool] = []
        for criterion in prompts:
            result = self.check_with_rules(soup, criterion)
            if result is None:
                excerpt = self.narrow_relevant_html(soup).get_text(" ", strip=True)[:1000]
                question = f"Yes or No: {criterion}? Context: {excerpt}"
                answer = ask_ai(question).strip().lower()
                result = answer.startswith("yes")
            results.append(result)
        return results


@app.post("/run", response_model=APIResponse)
def run_tests(data: InputData):
    runner = WebTestRunner(data.link)
    try:
        results = runner.check_page(data.link, data.criterias)
    except Exception as e:
        return APIResponse(status="error", error=str(e))

    response = [{'test': data.criterias[i], 'result': results[i]} for i in range(len(data.criterias))]

    # Prepare payload to send to Go API
    payload = {
        "criterias": data.criterias,
        "results": response
    }
    try:
        post_resp = requests.post(
            "http://go-api:8081/api/results",
            json=payload,
            timeout=5
        )
        post_resp.raise_for_status()
    except Exception as e:
        return APIResponse(status="error", error=f"Failed to send results: {e}")

    return APIResponse(status="success", data=payload)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=3000)
