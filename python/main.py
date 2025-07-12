import os
import logging
from typing import List, Any, Optional

import requests
from bs4 import BeautifulSoup
from fastapi import FastAPI
from pydantic import BaseModel
from openai import OpenAI
from selenium import webdriver
from selenium.webdriver.chrome.options import Options


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
        self.current_url = start_url
        self.current_html = ""

    def fetch_page(self, url: str) -> str:
        # Use headless Selenium to fetch the page HTML
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        driver = webdriver.Chrome(options=chrome_options)
        driver.get(url)
        # Wait for dynamic content if needed (could add explicit waits here)
        html = driver.page_source
        self.current_url = driver.current_url
        self.current_html = html
        driver.quit()
        return html

    def check_page(self, url: str, prompts: List[str]) -> List[bool]:
        # Fetch page via Selenium for JS-rendered content
        raw_html = self.fetch_page(url)
        soup = BeautifulSoup(raw_html, 'lxml')
        results: List[bool] = []
        for criterion in prompts:
            # Extract context for AI if no simple rule
            excerpt = soup
            c_lower = criterion.lower()
            # Choose prompt based on criterion template
            if c_lower.startswith("does") and "exist" in c_lower:
                instruct = (
                    "Please answer 'Yes' or 'No'.\n"
                    f"Criterion: \"{criterion}\" means check if the specified element exists on the page.\n"
                    "Example: Does logo exist? -> Yes if a logo image is present near the company name.\n"
                )
            elif c_lower.startswith("is") and "clickable" in c_lower:
                instruct = (
                    "Please answer 'Yes' or 'No'.\n"
                    f"Criterion: \"{criterion}\" means check if the specified element is clickable (e.g., links, buttons).\n"
                    "Example: Is 'Submit' button clickable? -> Yes if it responds to clicks.\n"
                )
            elif c_lower.startswith("does") and ("attribute" in c_lower or "value" in c_lower):
                instruct = (
                    "Please answer 'Yes' or 'No'.\n"
                    f"Criterion: \"{criterion}\" means check if the element has the given attribute or value.\n"
                    "Example: Does input have attribute 'placeholder'? -> Yes if the input tag includes placeholder attribute.\n"
                )
            else:
                instruct = (
                    "Please answer 'Yes' or 'No'.\n"
                    f"Criterion: \"{criterion}\". Assess based on page content intelligently.\n"
                )
            question = f"{instruct}Context: {excerpt}"
            answer = ask_ai(question).lower()
            f = open('output.txt', 'w')
            f.write(answer)
            f.close()
            logging.info("AI answer: %s", answer)
            result = answer.startswith("yes")
            results.append(result)
        return results


@app.post("/run", response_model=APIResponse)
def run_tests(data: InputData):
    runner = WebTestRunner(data.url)
    try:
        results = runner.check_page(data.url, data.tests)
    except Exception as e:
        return APIResponse(data=None)

    go_payload = [
        {"test": test, "result": result}
        for test, result in zip(data.tests, results)
    ]

    try:
        post_resp = requests.post(
            "http://go-api:8081/api/results",
            json=go_payload,
            timeout=5
        )
        post_resp.raise_for_status()
    except Exception as e:
        return APIResponse(data=None)

    print(go_payload)
    return APIResponse(data=go_payload)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=3000)
