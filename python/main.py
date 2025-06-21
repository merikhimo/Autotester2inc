import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin
import json
# from LLM import ask_ai
# from get_buttons import get_buttons
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
from huggingface_hub import InferenceClient


HF_TOKEN = "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"


def ask_ai(prompt: str):
    client = InferenceClient(
        provider="hf-inference",
        token=HF_TOKEN
    )

    response = client.chat_completion(
        model="microsoft/phi-4",
        messages=[{"role": "user", "content": prompt}]
    )
    return response.choices[0].message.content.strip()


# if __name__ == "__main__":
#     print(ask_ai("How are you?"))


app = FastAPI()



class WebTestRunner:
    def __init__(self, start_url):
        self.session = requests.Session()
        self.history = []
        self.current_url = start_url
        self.current_html = "НАЧАЛО"
        self.steps = []
        self.checked_pages = {}

    def fetch_page(self, url):
        response = self.session.get(url)
        self.current_url = response.url
        self.current_html = response.text
        return response.text

    def get_page_context(self, name='start_page'):
        soup = BeautifulSoup(self.current_html, 'lxml')
        self.checked_pages[name.lower()] = soup
        links = []
        for a in soup.find_all('a', href=True):
            if not a.get('href').startswith(('javascript:', '#')):
                link_text = a.text.strip() or a.get('href', '')[:50]
                links.append(f"[Ссылка]: {link_text}")

        forms = []
        for form in get_buttons(self.current_url, self.current_html):
            for btn_text in form['button_texts']:
                forms.append(f"[Кнопка]: {btn_text}")

        return {
            "current_url": self.current_url,
            "links": links,
            "buttons": forms
        }

    def execute_step(self, action_data):
        # print('step')
        action_type = action_data.get('action')
        target = action_data.get('target')
        reason = action_data.get('reason', '')

        if action_type == 'navigate':
            soup = BeautifulSoup(self.current_html, 'lxml')
            for a in soup.find_all('a', href=True):
                link_text = a.text.strip()
                href = a['href']

                if link_text == target or href == target:
                    abs_url = urljoin(self.current_url, href)
                    self.history.append({
                        'action': 'navigate',
                        'from': self.current_url,
                        'to': abs_url,
                        'reason': reason
                    })
                    self.fetch_page(abs_url)
                    return True
            return False

        elif action_type == 'submit_form':
            forms = get_buttons(self.current_url, self.current_html)
            for form in forms:
                if target in form['button_texts']:
                    form_data = {}
                    for inp in form['inputs']:
                        form_data[inp['name']] = inp['value'] or "test_value"

                    response = self.session.request(
                        method=form['method'],
                        url=form['action'],
                        data=form_data
                    )

                    self.history.append({
                        'action': 'submit',
                        'form': form['action'],
                        'button': target,
                        'data': form_data,
                        'reason': reason
                    })
                    self.current_url = response.url
                    self.current_html = response.text
                    return True
            return False

        return False

    def run(self, prompt, max_steps=10):
        self.fetch_page(self.current_url)

        while len(self.checked_pages) < max_steps:

            if len(self.history) == 0:
                context = self.get_page_context()
                llm_prompt = (
                    f'Шаг: 1'
                    f"Цель: {prompt}\n\n"
                    f"Текущая страница: {context['current_url']}\n"
                    f"Доступные действия:\n"
                    f"Ссылки: {', '.join(context['links'][:5])}{'...' if len(context['links']) > 5 else ''}\n"
                    "Какой следующий шаг? Ответ в формате JSON:\n"
                    '{"action": "navigate"|"complete", '
                    '"target": "текст ссылки или кнопки", "reason": "причина выбора"}'
                    'ОТВЕТ ОБЯЗАТЕЛЬНО В ФОРМАТЕ JSON!!!!!!, НИ ОТХОДИ НИКАК ОТ ЗАДАННОГО ФОРМАТА, НИ ЕДИНОГО ЛИШНЕГО СИМВОЛА'
                )
            else:
                context = self.get_page_context(self.steps[-1])
                llm_prompt = (
                    f'Шаг: {len(self.history)+1}'
                    f"Цель: {prompt}\n\n"
                    f"Текущая страница: {context['current_url']}\n"
                    f'Предыдущие шаги: {"->".join(self.steps)}'
                    f"Доступные действия:\n"
                    f"Ссылки: {', '.join(context['links'])}\n"
                    "Какой следующий шаг? Ответ в формате JSON:\n"
                    '{"action": "navigate"|"complete", '
                    '"target": "текст ссылки или кнопки", "reason": "причина выбора"}'
                    'ОТВЕТ ОБЯЗАТЕЛЬНО В ФОРМАТЕ JSON!!!!!!, НИ ОТХОДИ НИКАК ОТ ЗАДАННОГО ФОРМАТА, НИ ЕДИНОГО ЛИШНЕГО СИМВОЛА'
                    'В ответе дай ТОЧНОЕ НАЗВАНИЕ кнопки на которую надо нажать. Не переходи на сторонние сайты'
                )

            response = ask_ai(llm_prompt).replace('```json\n', '').replace('\n```', '') # .replace('\n', '')

            print(response)
            try:
                action_data = json.loads(response)
            except json.JSONDecodeError:
                self.history.append({'error': 'Invalid JSON from AI', 'response': response})
                break

            self.steps.append(action_data.get('target'))

            if action_data.get('action') == 'complete':
                self.history.append({
                    'action': 'complete',
                    'reason': action_data.get('reason', 'Task completed')
                })
                break

            if not self.execute_step(action_data):
                self.history.append({
                    'error': 'Action failed',
                    'target': action_data.get('target'),
                    'response': response
                })
                break

        return self.history

    def check_pages(self, prompt):
        # print(self.checked_pages.keys())
        for criteria in prompt:
            llm_prompt = \
                f'У меня есть критерий, на который нужно проверить какую-то страницу:\n'\
                f'Критерий: {criteria}\n'\
                f'Список страниц, которые я обошёл:'

            for page in self.checked_pages.keys(): llm_prompt += f'\n - {page}'

            llm_prompt += \
                '\nВ ответ мне нужно ОДНО СЛОВО - название страницы, которую нужно проверить на заданный критерий'\
                '\nРОВНО ОДНО СЛОВО, НИ ЕДИНОГО ЛИШНЕГО СЛОВА ИЛИ СИМВОЛА'
            response = ask_ai(llm_prompt).lower()

            print(response)

            page = self.checked_pages[response]

    def check_with_rules(self, soup, criterion):
        c = criterion.lower()
        if "login" in c:
            return bool(soup.find("input", {"type": "password"}))
        if "submit" in c or "button" in c:
            return bool(soup.find("button") or soup.find("input", {"type": "submit"}))
        if "header" in c and "welcome" in c:
            return bool(soup.find(lambda tag: tag.name in ["h1", "h2"] and "welcome" in tag.get_text().lower()))
        return None  # fallback to AI

    def narrow_relevant_html(self, soup):
        # Heuristic: find the largest <div> or <main>
        candidates = soup.find_all(['main', 'div'], recursive=True)
        return max(candidates, key=lambda tag: len(tag.get_text(strip=True)), default=soup)

    def check_page(self, link, prompts):
        response = self.session.get(link).text
        soup = BeautifulSoup(response, 'lxml')

        results = []
        for criterion in prompts:
            result = self.check_with_rules(soup, criterion)
            if result is None:  # fallback to AI if rule is unknown
                tag = self.narrow_relevant_html(soup)
                page_excerpt = tag.get_text(" ", strip=True)[:1000]
                question = f"Yes or No: {criterion}? Context: {page_excerpt}"
                answer = ask_ai(question).strip().lower()
                result = answer.startswith("yes")
            results.append(result)
        return results


# Модель запроса
class InputData(BaseModel):
    link: str
    criterias: List[str]


# Модель ответа
class OutputData(BaseModel):
    result: List[bool]


def get_buttons(base_url, html):
    soup = BeautifulSoup(html, 'lxml')
    forms = []

    for form in soup.find_all('form'):
        form_info = {
            'action': urljoin(base_url, form.get('action', '')),
            'method': form.get('method', 'GET').upper(),
            'inputs': [],
            'button_texts': []
        }

        for tag in form.find_all(['input', 'textarea', 'select']):
            if tag.get('type') in ['submit', 'button']:
                continue

            input_info = {
                'name': tag.get('name'),
                'type': tag.get('type', 'text'),
                'value': tag.get('value', '')
            }
            form_info['inputs'].append(input_info)

        # Собираем текст кнопок
        for button in form.find_all(['button', 'input']):
            if button.get('type') in ['submit', 'button']:
                text = button.text.strip()
                if not text and button.get('value'):
                    text = button.get('value').strip()
                if text:
                    form_info['button_texts'].append(text)

        forms.append(form_info)

    return forms


@app.post("/mvp_zero", response_model=OutputData)
def main(data: InputData):
    runner = WebTestRunner(data.link)
    return runner.check_page(data.link, data.criterias)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=3000)

    # START_URL = "https://arsenal-tools.net/"
    # prompt = input("Введите тестовый сценарий обхода: ")
    # criterias = []
    # print('Вводите критерии для проверки страницы:')
    # s = input()
    # while s:
    #     criterias.append(s)
    #     s = input()
    #
    #
    # runner = WebTestRunner(START_URL)
    # print(runner.check_page(START_URL, criterias))
    # # history = runner.run(prompt)
    # #
    # # print("\nИстория действий:")
    # # for i, step in enumerate(history):
    # #     print(f"{i + 1}. {step}")
    # #
    # # verification_result = runner.check_pages(criterias)

