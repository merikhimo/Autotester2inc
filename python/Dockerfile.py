FROM python:3.11

WORKDIR /app

# Установка системных зависимостей для language-tool-python
RUN apt-get update && apt-get install -y \
    openjdk-17-jre-headless \
    && rm -rf /var/lib/apt/lists/*

# Копирование requirements.txt (если есть)
COPY requirements.txt .

# Установка Python-зависимостей
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install language-tool-python fastapi uvicorn requests beautifulsoup4

# Копирование остальных файлов
COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
